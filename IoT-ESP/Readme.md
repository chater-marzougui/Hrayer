# ESP8266 IoT Sensor Monitor

An ESP8266-based IoT sensor monitoring system that reads environmental data from DHT22 (temperature and humidity) and capacitive soil moisture sensors, then sends the data to a cloud-hosted Express server via HTTPS with real-time WebSocket updates.

## Features

- 🌡️ **Temperature Monitoring** — DHT22 sensor for accurate temperature readings
- 💧 **Humidity Tracking** — Real-time humidity measurements
- 🌱 **Soil Moisture Detection** — Capacitive soil moisture sensor with percentage output
- 📡 **Cloud Connectivity** — Sends data to Heroku-hosted server every 5 seconds
- 🔒 **HTTPS Support** — Secure data transmission
- 🔄 **Auto-Reconnect** — Automatic WiFi reconnection on connection loss
- 📊 **Serial Monitoring** — Detailed debug output via Serial Monitor
- 💾 **Memory Efficient** — Optimized for ESP8266's limited resources

## Hardware Requirements

### Components

- **ESP8266 board** (NodeMCU, Wemos D1 Mini, or similar)
- **DHT22 sensor** (AM2302) - Temperature and humidity sensor
- **Capacitive soil moisture sensor** (analog output)
- **Jumper wires**
- **USB cable** for programming and power

### Wiring Diagram

#### DHT22 Sensor
| DHT22 Pin | ESP8266 Pin | Description |
|-----------|-------------|-------------|
| VCC       | 3.3V        | Power       |
| DATA      | D4 (GPIO2)  | Data signal |
| GND       | GND         | Ground      |

#### Soil Moisture Sensor
| Sensor Pin | ESP8266 Pin | Description |
|------------|-------------|-------------|
| VCC        | 3.3V        | Power       |
| AOUT       | A0          | Analog out  |
| GND        | GND         | Ground      |

```
ESP8266 NodeMCU Wiring:

        +---------------+
        |   ESP8266     |
        |   NodeMCU     |
        |               |
  3.3V  |[3V3]     [D4]|---- DHT22 Data
        |               |
    A0  |[A0]      [GND]|---- GND (Common)
        |               |
        +---------------+
              |
              |
         USB Power
```

## Software Requirements

### Arduino IDE Setup

1. **Install Arduino IDE** (version 1.8.x or 2.x)
   - Download from [arduino.cc](https://www.arduino.cc/en/software)

2. **Add ESP8266 Board Support**
   - Open Arduino IDE
   - Go to `File` → `Preferences`
   - Add to "Additional Board Manager URLs":
     ```
     http://arduino.esp8266.com/stable/package_esp8266com_index.json
     ```
   - Go to `Tools` → `Board` → `Boards Manager`
   - Search for "ESP8266" and install

3. **Install Required Libraries**
   - Go to `Sketch` → `Include Library` → `Manage Libraries`
   - Install the following:
     - **DHT sensor library** by Adafruit
     - **Adafruit Unified Sensor** (dependency for DHT)
     - ESP8266WiFi (built-in)
     - ESP8266HTTPClient (built-in)

## Configuration

### 1. WiFi Credentials

Edit the following lines in `IoT-ESP.ino`:

```cpp
const char* ssid = "YourWiFiName";      // Replace with your WiFi SSID
const char* password = "YourPassword";   // Replace with your WiFi password
```

### 2. Server URL

Update the server endpoint to point to your deployed backend:

```cpp
const char* serverUrl = "https://your-app-name.herokuapp.com/api/data";
```

### 3. Calibrate Soil Moisture Sensor

For accurate soil moisture readings, calibrate your sensor:

```cpp
const int AIR_VALUE = 620;    // Sensor value in air (dry)
const int WATER_VALUE = 310;  // Sensor value in water (wet)
```

**Calibration steps:**
1. Upload the code and open Serial Monitor
2. Note the raw value when sensor is in air (completely dry)
3. Note the raw value when sensor is in water (completely wet)
4. Update `AIR_VALUE` and `WATER_VALUE` accordingly
5. Re-upload the code

## Installation & Usage

### 1. Configure Board Settings

In Arduino IDE, select:
- **Board**: "NodeMCU 1.0 (ESP-12E Module)" or your specific ESP8266 board
- **Upload Speed**: 115200
- **CPU Frequency**: 80 MHz
- **Flash Size**: 4MB (depending on your board)
- **Port**: Select the COM port your ESP8266 is connected to

### 2. Upload the Code

1. Open `IoT-ESP.ino` in Arduino IDE
2. Update WiFi credentials and server URL
3. Click the **Upload** button (→)
4. Wait for upload to complete

### 3. Monitor Serial Output

1. Open Serial Monitor (`Tools` → `Serial Monitor`)
2. Set baud rate to **115200**
3. You should see connection status and sensor readings

### Expected Serial Output

```
=== ESP8266 Sensor Monitor ===
DHT22 initialized
Soil moisture sensor initialized
Connecting to WiFi: YourWiFiName
.....
WiFi connected!
IP address: 192.168.1.100
Signal strength (RSSI): -45 dBm
Setup complete!

--- Reading Sensors ---
Temperature: 24.3 °C
Humidity: 65.2 %
Soil Moisture: 45 % (raw: 465)
Sending data to: https://your-server.com/api/data
Payload: {"temp":24.3,"humidity":65.2,"moisture":45}
HTTP Response code: 200
✓ Data sent successfully!
Free Heap: 35248 bytes
```

## Data Format

The ESP8266 sends data as JSON via HTTP POST:

```json
{
  "temp": 24.3,
  "humidity": 65.2,
  "moisture": 45
}
```

**Fields:**
- `temp` — Temperature in Celsius (float, 1 decimal place)
- `humidity` — Relative humidity in percentage (float, 1 decimal place)
- `moisture` — Soil moisture in percentage (integer, 0-100)

## Timing Configuration

The default sending interval is 5 seconds. To change it, modify:

```cpp
const unsigned long sendInterval = 5000; // Time in milliseconds
```

**Recommended intervals:**
- Testing: 3000-5000 ms (3-5 seconds)
- Normal operation: 30000-60000 ms (30-60 seconds)
- Battery powered: 300000+ ms (5+ minutes)

## Troubleshooting

### WiFi Connection Issues

**Problem:** ESP8266 fails to connect to WiFi
- Verify SSID and password are correct
- Ensure 2.4GHz WiFi (ESP8266 doesn't support 5GHz)
- Check WiFi signal strength
- Try moving closer to the router

### DHT22 Sensor Errors

**Problem:** "Failed to read from DHT sensor"
- Check wiring connections
- Ensure DHT22 is properly powered (3.3V)
- Add a 10kΩ pull-up resistor between DATA and VCC
- Try a different GPIO pin

### HTTP Request Failures

**Problem:** "HTTP Error" or timeout
- Verify server URL is correct and accessible
- Check internet connectivity
- Ensure server is running and healthy
- Increase timeout value if needed:
  ```cpp
  http.setTimeout(15000); // 15 second timeout
  ```

### Soil Moisture Readings Inaccurate

**Problem:** Moisture readings always 0% or 100%
- Recalibrate sensor (see Calibration section)
- Check analog pin connection (A0)
- Ensure sensor is properly powered
- Test sensor in different moisture conditions

### Memory Issues

**Problem:** ESP8266 crashes or resets
- The code is optimized for low memory usage
- Reduce debug output if needed
- Increase sending interval to reduce HTTP overhead

## Pin Reference

### NodeMCU Pin Mapping

| NodeMCU Label | GPIO | Arduino Pin | Function |
|---------------|------|-------------|----------|
| D0            | 16   | 16          | Wake     |
| D1            | 5    | 5           | I2C SCL  |
| D2            | 4    | 4           | I2C SDA  |
| D3            | 0    | 0           | Flash    |
| D4            | 2    | 2           | **DHT22**|
| D5            | 14   | 14          | SPI CLK  |
| D6            | 12   | 12          | SPI MISO |
| D7            | 13   | 13          | SPI MOSI |
| D8            | 15   | 15          | SPI CS   |
| A0            | ADC  | A0          | **Soil** |

## Power Consumption

- **Active (WiFi transmitting)**: ~170mA
- **Active (WiFi idle)**: ~70mA
- **Deep sleep**: ~20µA (not implemented in this version)

For battery operation, consider implementing deep sleep between readings.

## Backend Integration

This ESP8266 code is designed to work with the WieAct backend server. Make sure:

1. Backend server is deployed and running
2. Server URL is correctly configured in the code
3. Server accepts POST requests at `/api/data` endpoint
4. HTTPS certificate validation is handled (currently using `setInsecure()`)

## Future Enhancements

- [ ] Deep sleep mode for battery operation
- [ ] OTA (Over-The-Air) firmware updates
- [ ] Multiple sensor support
- [ ] Local data buffering when server is unavailable
- [ ] MQTT protocol support
- [ ] Certificate pinning for enhanced security

## License

MIT

## Author

Created for WieAct IoT Dashboard project
