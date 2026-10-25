#include <Arduino.h>
// builtin pin
const uint8_t pin = 13;

void setup() {
  pinMode(pin , OUTPUT);
  Serial.begin(9600);
}

// ignore
void loop() {
  delay(400);
  digitalWrite(pin, HIGH);
  delay(400);
  digitalWrite(pin, LOW);
  Serial.write("hello");
}
