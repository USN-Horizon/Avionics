#include <FreeRTOS.h>
#include <task.h>
#include <semphr.h>
#include <Arduino.h>

SemaphoreHandle_t serial_mutex;

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
    xSemaphoreTake(serial_mutex, portMAX_DELAY);
    Serial.printf("tick %lu\n", n++);
    xSemaphoreGive(serial_mutex);
    vTaskDelay(pdMS_TO_TICKS(10));
  }
}

void setup() {
  Serial.begin(115200);

  static StaticSemaphore_t mutex_state;
  static StaticTask_t blink_task_buf;
  static StaticTask_t print_task_buf;

  serial_mutex = xSemaphoreCreateMutexStatic(&mutex_state);
  xTaskCreateStatic(blinkTask, "blink", 256, nullptr, 1, nullptr, &blink_task_buf);
  xTaskCreateStatic(printTask, "print", 512, nullptr, 1, nullptr, &print_task_buf);

  vTaskStartScheduler();  // never returns
}

void loop() {} // never reached
