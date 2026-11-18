#include <Arduino.h>

// Define the built-in LED pin for the Seeed Wio-E5 mini / STM32WL board
// (PC13 or LED_BUILTIN is standard on most STM32WL dev boards)
#ifndef LED_BUILTIN
#define LED_BUILTIN PC13
#endif

void setup() {
  // Initialize Serial (USART1) routed to the USB-C port
  Serial.begin(9600);
  
  // Optional safety timeout: wait up to 3 seconds for the serial monitor to attach, 
  // ensuring the board doesn't freeze if running standalone on USB power/battery.
  unsigned long startTime = millis();
  while (!Serial && (millis() - startTime < 3000));

  // Configure the LED pin as an output
  pinMode(LED_BUILTIN, OUTPUT);
  
  Serial.println(F("[Test] Serial and LED initialized successfully!"));
}

void loop() {
  static unsigned long counter = 1;

  // Print the incrementing message to the serial monitor
  Serial.print(counter);
  Serial.println(F(" blinking"));

  // Toggle the LED state (ON/OFF)
  digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));

  // Wait 1 second before the next cycle
  delay(1000);
  
  counter++;
}