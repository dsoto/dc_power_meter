#include <LiquidCrystal.h>
LiquidCrystal lcd(8,7,6,5,4,3);

int voltagePin = A0;    
int currentPin = A1;

float voltage = 0;
float current = 0;
float   power = 0;

void setup() {
  Serial.begin(9600);
  lcd.begin(16,1);
  Serial.println("DC Power Meter");
}

void loop() {
  // figure out how to get current and previous sample times
  voltage = analogRead(voltagePin) * 5.0 / 1024.0 * 2.0;
  current = analogRead(currentPin) * 5.0 / 1024.0 * 10.0;
  if (current < 0.8) current = 0;
  power = voltage * current;

  // output to serial
  Serial.print(millis());
  Serial.print(", ");
  Serial.print(voltage, DEC);
  Serial.print(", ");
  Serial.print(current, DEC);
  Serial.print(", ");
  Serial.print(power, DEC);
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
  
  // sample at ~1 Hz  
  delay(200);
}
