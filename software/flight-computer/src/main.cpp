#include <Arduino.h>
#include <STM32FreeRTOS.h>

SemaphoreHandle_t serialMutex;

void blinkTask(void *) {
  pinMode(PC13, OUTPUT);              // onboard LED, active low
  for (;;) {
    digitalToggle(PC13);
    vTaskDelay(pdMS_TO_TICKS(1000));
  }
}

void printTask(void *) {
  uint32_t n = 0;
  for (;;) {
    xSemaphoreTake(serialMutex, portMAX_DELAY);
    Serial.printf("tick %lu\n", n++);
    xSemaphoreGive(serialMutex);
    vTaskDelay(pdMS_TO_TICKS(10));
  }
}

void setup() {
  Serial.begin(115200);
  serialMutex = xSemaphoreCreateMutex();
  xTaskCreate(blinkTask, "blink", 256, nullptr, 1, nullptr);
  xTaskCreate(printTask, "print", 512, nullptr, 1, nullptr);
  vTaskStartScheduler();              // never returns
}

void loop() {}