/*
 * Capacitive Soil Moisture Sensor Calibration Tool
 * 
 * Hardware Connections:
 * - Soil Moisture Sensor: Analog output to A0
 * - Push Button: One side to D5 (GPIO14), other side to GND
 *   (uses internal pull-up resistor)
 * 
 * Instructions:
 * 1. Upload sketch and open Serial Monitor (115200 baud)
 * 2. Follow on-screen prompts
 * 3. Press button to start air calibration
 * 4. Keep sensor in air for 10 seconds
 * 5. Press button again to start water calibration
 * 6. Submerge sensor in water for 10 seconds
 * 7. Copy the AIR_VALUE and WATER_VALUE from results
 */

#define SOIL_PIN A1
#define BUTTON_PIN 2  // D5 on NodeMCU

// Calibration settings
const int SAMPLES_PER_READING = 100;
const int READING_DELAY = 100;  // 100ms between samples = 10 seconds total

// State machine
enum CalibrationState {
  WAITING_FOR_AIR_START,
  READING_AIR,
  WAITING_FOR_WATER_START,
  READING_WATER,
  COMPLETE
};

CalibrationState state = WAITING_FOR_AIR_START;

// Calibration data
long airSum = 0;
long waterSum = 0;
int airValue = 0;
int waterValue = 0;
int sampleCount = 0;

// Button debouncing
bool lastButtonState = HIGH;
unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 50;

void setup() {
  Serial.begin(115200);
  delay(100);
  
  // Initialize pins
  pinMode(SOIL_PIN, INPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  
  Serial.println("Hardware initialized");
  Serial.println("Ready to calibrate!\n");
  
  printInstructions();
}

void loop() {
  // Read button with debouncing
  bool buttonPressed = checkButton();
  
  switch (state) {
    case WAITING_FOR_AIR_START:
      if (buttonPressed) {
        startAirCalibration();
      }
      break;
      
    case READING_AIR:
      if (sampleCount < SAMPLES_PER_READING) {
        takeSample(true);  // true = air calibration
      } else {
        finishAirCalibration();
      }
      break;
      
    case WAITING_FOR_WATER_START:
      if (buttonPressed) {
        startWaterCalibration();
      }
      break;
      
    case READING_WATER:
      if (sampleCount < SAMPLES_PER_READING) {
        takeSample(false);  // false = water calibration
      } else {
        finishCalibration();
      }
      break;
      
    case COMPLETE:
      // Do nothing, calibration complete
      delay(100);
      break;
  }
}

bool checkButton() {
  return !digitalRead(BUTTON_PIN);
}

void printInstructions() {
  Serial.println("═══════════════════════════════════════════════════");
  Serial.println("→ Keep the sensor in DRY AIR (not touching anything)");
  Serial.println("→ Press the button when ready to start");
}

void startAirCalibration() {
  Serial.println("\n╔═══════════════════════════════════════════════════╗");
  Serial.println("║  STARTING AIR CALIBRATION                        ║");
  Serial.println("Keep sensor in dry air!\n");
  
  state = READING_AIR;
  airSum = 0;
  sampleCount = 0;
  
  Serial.println("Sample | Raw Value | Progress");
  Serial.println("-------|-----------|------------------");
}

void startWaterCalibration() {
  Serial.println("║  STARTING WATER CALIBRATION                      ║");
  Serial.println("Reading 100 samples over 10 seconds...");
  Serial.println("Keep sensor fully submerged in water!\n");
  
  state = READING_WATER;
  waterSum = 0;
  sampleCount = 0;
  
  Serial.println("Sample | Raw Value | Progress");
  Serial.println("-------|-----------|------------------");
}

void takeSample(bool isAir) {
  int rawValue = analogRead(SOIL_PIN);
  
  if (isAir) {
    airSum += rawValue;
  } else {
    waterSum += rawValue;
  }
  
  sampleCount++;
  
  // Print progress every 10 samples
  if (sampleCount % 10 == 0 || sampleCount == 1) {
    Serial.print("  ");
    Serial.print(sampleCount);
    Serial.print("   |   ");
    Serial.print(rawValue);
    Serial.print("    | ");
    
    // Progress bar
    int progress = (sampleCount * 20) / SAMPLES_PER_READING;
    for (int i = 0; i < progress; i++) {
      Serial.print("█");
    }
    Serial.println();
  }
  
  delay(READING_DELAY);
}

void finishAirCalibration() {
  airValue = airSum / SAMPLES_PER_READING;
  
  Serial.println("\nAir calibration complete!");
  Serial.print("→ Average AIR value: ");
  Serial.println(airValue);
  Serial.println();
  
  Serial.println("═══════════════════════════════════════════════════");
  Serial.println("STEP 2: WATER CALIBRATION");
  Serial.println("→ Submerge the sensor FULLY in water");
  Serial.println("→ Press the button when ready to start");
  
  state = WAITING_FOR_WATER_START;
  sampleCount = 0;
}

void finishCalibration() {
  waterValue = waterSum / SAMPLES_PER_READING;
  
  Serial.println("\nWater calibration complete!");
  Serial.print("→ Average WATER value: ");
  Serial.println(waterValue);
  Serial.println();
  
  // Print final results
  printResults();
  
  state = COMPLETE;
}

void printResults() {
  Serial.println("─────────────────────────────────────────────────────");
  Serial.println("CALIBRATION RESULTS:");
  Serial.println("─────────────────────────────────────────────────────");
  Serial.print("AIR_VALUE (dry):   ");
  Serial.println(airValue);
  Serial.print("WATER_VALUE (wet): ");
  Serial.println(waterValue);
  Serial.print("Range:             ");
  Serial.println(airValue - waterValue);
  Serial.println("─────────────────────────────────────────────────────\n");
  
  Serial.println("📋 COPY THESE VALUES TO YOUR MAIN SKETCH:\n");
  Serial.println("const int AIR_VALUE = " + String(airValue) + ";    // Value in air (dry)");
  Serial.println("const int WATER_VALUE = " + String(waterValue) + ";  // Value in water (wet)");
  Serial.println();
  
  // Validation check
  if (airValue <= waterValue) {
    Serial.println("WARNING: AIR_VALUE should be HIGHER than WATER_VALUE!");
    Serial.println("Please repeat calibration - something went wrong.");
  } else if (airValue - waterValue < 100) {
    Serial.println("WARNING: Range is very small (< 100).");
    Serial.println("Sensor might not be working correctly.");
  } else {
    Serial.println("Calibration values look good!");
    Serial.println("You can now use these in your main sketch.");
  }
}