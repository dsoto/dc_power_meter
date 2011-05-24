#include <LiquidCrystal.h>
LiquidCrystal lcd(8,7,6,5,4,3);

int voltagePin = A0;
int currentPin = A1;

float voltage = 0;
float current = 0;
float   power = 0;

// voltage calibration
int adcV2 = 497;
int adcV1 = 0;
float V2 = 4.85;
float V1 = 0;
float Voffset = - (adcV2 - adcV1) / (V2 - V1) * V1 + adcV1;
float Vgain = V2 / (adcV2 - Voffset);

// current calibration
int adcI2 = 111;
int adcI1 = 9;
float I2 = 48.2;
float I1 = 0;
float Ioffset = - (adcI2 - adcI1) / (I2 - I1) * I1 + adcI1;
float Igain = I2 / (adcI2 - Ioffset);


void setup() {
  Serial.begin(9600);
  lcd.begin(16,1);
  Serial.println("DC Power Meter");
}

void loop() {
  /*
  // i want these both as static but the compiler won't let me
  unsigned long lastTime = 0;
  unsigned long thisTime = millis();
  */
  
  // figure out how to get current and previous sample times
  int dacA0 = analogRead(voltagePin);
  int dacA1 = analogRead(currentPin);

  float voltage = (dacA0 - Voffset) * Vgain;
  float current = (dacA1 - Ioffset) * Igain;

  power = voltage * current;
  
  // output to serial
  Serial.print(millis());
  Serial.print(", ");
  Serial.print(voltage, DEC);
  Serial.print(", ");
  Serial.print(current, DEC);
  Serial.print(", ");
  Serial.print(power, DEC);
  Serial.print(", ");
  Serial.print(dacA0, DEC);
  Serial.print(", ");
  Serial.print(dacA1, DEC);
  Serial.println();
  

  // output to LCD
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(voltage, 1);
  lcd.print("V ");
  lcd.print(current, 0);
  lcd.print("mA ");
  lcd.print(power, 0);
  lcd.print("mW");

  /*
  float energyAccumulated = power * (thisTime - lastTime) / 1000;
  float averagePower = energyAccumulated / millis() * 1000;
  lastTime = thisTime;
  */
  
  delay(200);
}

// todo - add accumulator for average power
// todo - add larger lcd display
