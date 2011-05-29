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

  float maxPower = 0;
  float maxCurrent = 0;
  float maxVoltage = 0;

  float minPower = 9999;
  float minCurrent = 999;
  float minVoltage = 9.9;
  
const int nBoxcar = 50;
float powerArray[nBoxcar];
char outString[21];

void setup() {
  Serial.begin(9600);
  lcd.begin(20,4);
  Serial.println("DC Power Meter");
}

void loop() {
  static int i = 0;

  // figure out how to get current and previous sample times
  int dacA0 = analogRead(voltagePin);
  int dacA1 = analogRead(currentPin);

  float voltage = (dacA0 - Voffset) * Vgain;
  float current = (dacA1 - Ioffset) * Igain;

  power = voltage * current;

  if (++i == nBoxcar) i = 0;
  powerArray[i] = power;
  float avgPower = 0;
  for (int j=0; j < nBoxcar; j++) {
    avgPower += powerArray[j] / nBoxcar;
  }



  // set maximums
  if (power > maxPower)       maxPower = power;
  if (current > maxCurrent) maxCurrent = current;
  if (voltage > maxVoltage) maxVoltage = voltage;

  if (power   < minPower)     minPower = power;
  if (current < minCurrent) minCurrent = current;
  if (voltage < minVoltage) minVoltage = voltage;

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
  //lcd.clear();
  
  // first LCD line
  lcd.setCursor(0, 0);
  int index = 0;
  placeDigitsInArray(outString, &index, voltage, 4, 1);
  outString[index++] = 'V'; 
  placeDigitsInArray(outString, &index, current, 4, 0);
  outString[index++] = 'm';
  outString[index++] = 'A'; 
  placeDigitsInArray(outString, &index, power, 5, 0); 
  outString[index++] = 'm';
  outString[index++] = 'W'; 
  outString[index++] = 0;
  lcd.print(outString);
  
  // average values on second LCD line
  lcd.setCursor(0, 1);
  index = 0;
  outString[index++] = 'a'; 
  outString[index++] = 'v';
  placeDigitsInArray(outString, &index, 0.0, 2, 1);
  placeDigitsInArray(outString, &index, 0.0, 5, 0);
  placeDigitsInArray(outString, &index, avgPower, 7, 0);
  outString[index++] = 0;
  lcd.print(outString);

  // maximum values on LCD
  lcd.setCursor(0, 2);
  index = 0;
  outString[index++] = 'm'; 
  outString[index++] = 'x';
  placeDigitsInArray(outString, &index, maxVoltage, 2, 1);
  placeDigitsInArray(outString, &index, maxCurrent, 5, 0);
  placeDigitsInArray(outString, &index, maxPower, 7, 0);
  outString[index++] = 0;
  lcd.print(outString);

  // minimum values on LCD
  lcd.setCursor(0, 3);
  index = 0;
  outString[index++] = 'm'; 
  outString[index++] = 'n';
  placeDigitsInArray(outString, &index, minVoltage, 2, 1);
  placeDigitsInArray(outString, &index, minCurrent, 5, 0);
  placeDigitsInArray(outString, &index, minPower, 7, 0);
  outString[index++] = 0;
  lcd.print(outString);

  delay(200);
}


void placeDigitsInArray(char * outString, 
                        int * index,
                        float value, 
                        int d, 
                        int p){
  // places value in outstring formatted with d characters and p precision
  // no attempts at rounding
  for (int i=d;i>0;i--) {
    int digit = (int)(value / pow(10, i-1));
    value = value - digit * pow(10, i-1);
    if (digit == 0){
      outString[(*index)++] = ' ';
    } else {
      outString[(*index)++] = digit + 0x30;
    }
  }
  if (p > 0) {
    outString[(*index)++] = '.';
    for (int i = 0; i < p; i++) {
      int digit = (int)(value * 10);
      value = value*10 - digit;
      outString[(*index)++] = digit + 0x30;
    }
  }
}

