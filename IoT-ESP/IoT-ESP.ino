#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <DHT.h>

// WiFi Credentials
const char* ssid = "Note13";
const char* password = "chater123";

// Server Configuration
const char* serverUrl = "https://wie-act-1faad7d7a3cf.herokuapp.com/api/data";

// DHT22 Configuration
#define DHTPIN 2          // GPIO2 (D4 on NodeMCU)
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// Soil Moisture Sensor Configuration
#define SOIL_PIN A0
const int AIR_VALUE = 700;    // Value in air (dry) - calibrate for your sensor
const int WATER_VALUE = 430;  // Value in water (wet) - calibrate for your sensor

// Timing
unsigned long lastSendTime = 0;
const unsigned long sendInterval = 5000; // 5 seconds

// WiFi Client
WiFiClientSecure client;

void setup() {
  Serial.begin(115200);
  delay(100);
  
  // Initialize DHT sensor
  dht.begin();
  Serial.println("DHT22 initialized");
  // Connect to WiFi
  connectWiFi();

  
  
  Serial.println("\n\n=== ESP8266 Sensor Monitor ===");
  
  // Initialize soil moisture sensor
  pinMode(SOIL_PIN, INPUT);
  Serial.println("Soil moisture sensor initialized");
  
  // Configure SSL client (ignore certificate validation for Heroku)
  client.setInsecure();
  
  Serial.println("Setup complete!\n");
}

void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected. Reconnecting...");
    connectWiFi();
  }
  
  // Send data every 5 seconds
  if (millis() - lastSendTime >= sendInterval) {
    readAndSendData();
    lastSendTime = millis();
  }
  
  // Small delay to prevent watchdog timer issues
  delay(10);
}

void connectWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    Serial.print("Signal strength (RSSI): ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
  } else {
    Serial.println("\nWiFi connection failed!");
    delay(5000);
    ESP.restart(); // Restart if WiFi fails
  }
}

void readAndSendData() {
  Serial.println("\n--- Reading Sensors ---");
  
  // Read DHT22
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  
  // Read soil moisture
  int soilRaw = analogRead(SOIL_PIN);
  int moisture = map(soilRaw, AIR_VALUE, WATER_VALUE, 0, 100);
  moisture = constrain(moisture, 0, 100); // Keep within 0-100%

  
  
  Serial.print("Soil Moisture: ");
  Serial.print(moisture);
  Serial.print(" % (raw: ");
  Serial.print(soilRaw);
  Serial.println(")");
  
  // Check if DHT readings are valid
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("ERROR: Failed to read from DHT sensor!");
    return;
  }
  
  // Display readings
  Serial.print("Temperature: ");
  Serial.print(temperature, 1);
  Serial.println(" °C");
  
  Serial.print("Humidity: ");
  Serial.print(humidity, 1);
  Serial.println(" %");
  
  // Send data to server
  sendDataToServer(temperature, humidity, moisture, soilRaw);
  
  // Print memory usage
  Serial.print("Free Heap: ");
  Serial.print(ESP.getFreeHeap());
  Serial.println(" bytes");
}

void sendDataToServer(float temp, float humidity, int moisture, int soilRaw) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("ERROR: Not connected to WiFi!");
    return;
  }
  
  HTTPClient http;
  
  Serial.print("Sending data to: ");
  Serial.println(serverUrl);
  
  // Begin HTTP connection
  http.begin(client, serverUrl);
  http.addHeader("Content-Type", "application/json");
  http.setTimeout(10000); // 10 second timeout
  
  // Create JSON payload with reduced precision to save memory
  String payload = "{\"temp\":";
  payload += String(temp, 1);
  payload += ",\"humidity\":";
  payload += String(humidity, 1);
  payload += ",\"moisture\":";
  payload += String(moisture);
  payload += ",\"soilRaw\":";
  payload += String(soilRaw);
  payload += "}";
  
  Serial.print("Payload: ");
  Serial.println(payload);
  
  // Send POST request
  int httpResponseCode = http.POST(payload);
  
  // Handle response
  if (httpResponseCode > 0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    
    if (httpResponseCode == 200 || httpResponseCode == 201) {
      Serial.println("✓ Data sent successfully!");
      
      // Only read response if needed (saves memory)
      String response = http.getString();
      if (response.length() < 200) { // Only print short responses
        Serial.print("Server response: ");
        Serial.println(response);
      }
    } else {
      Serial.println("✗ Server returned error code");
    }
  } else {
    Serial.print("✗ HTTP Error: ");
    Serial.println(http.errorToString(httpResponseCode));
  }
  
  // Clean up
  http.end();
}