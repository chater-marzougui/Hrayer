/*
 * ESP8266 Sensor Client for WieAct Dashboard
 * 
 * Reads temperature, humidity, and soil moisture sensors
 * and sends data to your WieAct server via HTTP POST
 * 
 * Required Libraries:
 * - ESP8266WiFi (included with ESP8266 board package)
 * - ESP8266HTTPClient (included with ESP8266 board package)
 * - ArduinoJson (install from Library Manager)
 */

#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Server URL - replace with your Heroku app URL or local IP
const char* serverUrl = "http://your-app-name.herokuapp.com/api/data";
// For local testing: "http://192.168.1.100:3000/api/data"

// Sensor pins (adjust based on your wiring)
#define TEMP_PIN A0        // Analog temperature sensor
#define MOISTURE_PIN A0    // Soil moisture sensor

// Send interval (milliseconds)
const unsigned long SEND_INTERVAL = 5000; // 5 seconds
unsigned long lastSendTime = 0;

WiFiClient wifiClient;

void setup() {
  Serial.begin(115200);
  delay(100);
  
  Serial.println("\n🌱 WieAct ESP8266 Sensor Client");
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\n✅ WiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  unsigned long currentTime = millis();
  
  // Send data at regular intervals
  if (currentTime - lastSendTime >= SEND_INTERVAL) {
    sendSensorData();
    lastSendTime = currentTime;
  }
}

void sendSensorData() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("❌ WiFi disconnected!");
    return;
  }
  
  // Read sensor values (replace with your actual sensor code)
  float temperature = readTemperature();
  float humidity = readHumidity();
  int moisture = readMoisture();
  
  // Create JSON document
  StaticJsonDocument<200> doc;
  doc["temp"] = temperature;
  doc["humidity"] = humidity;
  doc["moisture"] = moisture;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  // Send HTTP POST request
  HTTPClient http;
  http.begin(wifiClient, serverUrl);
  http.addHeader("Content-Type", "application/json");
  
  int httpCode = http.POST(jsonString);
  
  if (httpCode > 0) {
    if (httpCode == HTTP_CODE_CREATED || httpCode == HTTP_CODE_OK) {
      Serial.println("✅ Data sent successfully!");
      Serial.println("📊 " + jsonString);
    } else {
      Serial.printf("⚠️ Unexpected response: %d\n", httpCode);
    }
  } else {
    Serial.printf("❌ POST failed: %s\n", http.errorToString(httpCode).c_str());
  }
  
  http.end();
}

// Replace these functions with your actual sensor reading code
float readTemperature() {
  // Example: DHT22, DS18B20, or analog temperature sensor
  // This is a placeholder that returns a simulated value
  return 20.0 + random(0, 100) / 10.0; // 20-30°C
}

float readHumidity() {
  // Example: DHT22 humidity sensor
  // This is a placeholder that returns a simulated value
  return 50.0 + random(0, 300) / 10.0; // 50-80%
}

int readMoisture() {
  // Example: Capacitive or resistive soil moisture sensor
  // This is a placeholder that returns a simulated value
  return 300 + random(0, 200); // 300-500
  
  // For real sensor: return analogRead(MOISTURE_PIN);
}
