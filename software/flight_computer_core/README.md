# Rocket Firmware

C++ flight software for a small rocket. The final target is an **STM32H753** microcontroller (NUCLEO-H753ZI board).

> **Open decision:** the real sensors are **not chosen yet** (barometer, IMU, GPS, radio). Everything about real sensors below is a plan.

## 1. Main idea

**Write the flight logic once, and run it in three places.** Only the hardware-specific code changes.

| Step | Where it runs | Sensors | CPU | Status |
| --- | --- | --- | --- | --- |
| 1. PC build | Windows PC | Simulated | PC (x64) | **Done** (simulated sensors only) |
| 2. Renode build | [Renode](https://renode.io) emulator (virtual NUCLEO-H753ZI) | Still simulated | ARM Cortex-M7 | Planned |
| 3. Hardware build | The real board | **Real sensor readings** | ARM Cortex-M7 | Planned |

- **Step 1 (PC):** fast to build and debug. We test the logic with fake data.
- **Step 2 (Renode):** the same fake data, but now the code is compiled for the **ARM** chip and runs in an emulator. This finds ARM problems (startup code, memory, FreeRTOS) before we need the board.
- **Step 3 (hardware):** we replace the simulated sensors with real drivers that read the real sensors. The flight logic does not change.

Going from step 1 to 2 changes the **compiler and the startup code**. Going from step 2 to 3 changes the **sensors**.

### Why we do it this way

| Decision | Why |
| --- | --- |
| **Start on the PC** | A PC build takes seconds. Flashing a board and waiting for the hardware is slow. We can try an idea, run it and see the result right away. |
| **Debug on the PC** | We can use breakpoints, step through the code, watch variables and print anything. On the real board this is harder and has less room. We get the flight logic right here first. |
| **Simulated sensors with known data** | We choose the numbers, so we know what the code should do. We can also make a sensor fail (`valid = false`) whenever we want. Real sensors will not do that on command. |
| **Flight logic separate from hardware** | The logic does not include STM32 or FreeRTOS code (see `ISensor` below). That is what lets us run it on the PC and test it. |
| **Unit tests** | Small automatic tests that run on the PC. Each test feeds the logic a known list of readings (using `ReplaySensor`) and checks the result, for example: "a bad reading is skipped" or "the rocket is detected as launched". We run them after every change, so we notice quickly if something breaks. |
| **Renode before the real board** | We find ARM problems (startup code, memory, FreeRTOS) without hardware, and we can run the same tests again. |
| **Real hardware last** | It is the slowest to work with, so we only go there when the logic already works. Then only the sensor drivers are new. |

## 2. How the code stays the same: `ISensor`

See [src/sensors/i_sensor.hpp](src/sensors/i_sensor.hpp).

```cpp
struct Reading {
    double value = 0.0;
    bool valid = false;   // false = sensor failed, do not use value
};

class ISensor {
public:
    virtual ~ISensor() = default;
    virtual Reading read() = 0;
};
```

The flight logic only knows `ISensor`. It does not know if the number comes from a simulator or a real sensor.

```text
 Flight logic  --uses-->  ISensor  <--implemented by--  Simulated sensors   (steps 1 and 2)
                                   <--implemented by--  Real drivers        (step 3)
```

Rules:

- **One sensor, one number.** `read()` returns one `Reading`.
- **Always check `valid`** before using `value`. A default `Reading` is invalid.
- **Units are in the code comments** (metres, m/s, m/s², degrees/s).
- **Flight logic never touches hardware.** No STM32 headers, no registers.

## 3. What exists today

| File | What it does |
| --- | --- |
| [src/sensors/i_sensor.hpp](src/sensors/i_sensor.hpp) | The `ISensor` interface |
| [src/sensors/replay_sensor.hpp](src/sensors/replay_sensor.hpp) | `ReplaySensor`: returns a hand-written list of readings, one per `read()` |
| [src/sensors/sensor_simulators.hpp](src/sensors/sensor_simulators.hpp) | Altitude, velocity, acceleration, gyroscope and GPS simulators |
| [app/main.cpp](app/main.cpp) | Reads all sensors once per second for 5 seconds and prints a table |

- Each simulator has 5 made-up readings. After the last one, `read()` returns an invalid reading.
- The gyroscope has one invalid reading on purpose. [app/main.cpp](app/main.cpp) prints "bad reading, skipped" for that row.
- The GPS gives only one number for now: the distance from the launch pad.

## 4. Install, build and run (PC)

### Install (Windows 11)

Open a terminal and run these `winget` commands:

| Tool | Why | Command |
| --- | --- | --- |
| Visual Studio Code | The editor | `winget install --id Microsoft.VisualStudioCode -e` |
| CMake | Makes the build files | `winget install --id Kitware.CMake -e` |
| Visual Studio 2022 Build Tools (C++ workload) | The C++ compiler and Windows SDK | `winget install --id Microsoft.VisualStudio.2022.BuildTools -e --override "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --passive"` |
| C/C++ extension for VS Code | Run and debug with `F5` | `code --install-extension ms-vscode.cpptools` |

Notes:

- You need **Visual Studio 2022** and **CMake 3.20 or newer**. The project uses C++20.
- The C/C++ extension already has the debugger that [.vscode/launch.json](.vscode/launch.json) uses.
- Close and reopen your terminal and VS Code after installing, so `cmake` is found.

### Build and run

```bat
build.bat
```

This makes a Debug build and runs it.

## 5. Future plan

### Target board

| Item | Value |
| --- | --- |
| Board | NUCLEO-H753ZI (built-in ST-LINK programmer and debugger) |
| CPU | Arm Cortex-M7, up to 480 MHz, hardware `double` support |
| Flash / RAM | 2 MB / up to 1 MB |
| Logic level | 3.3 V |

The chip is powerful enough for our flight logic. Sources: [STM32H753ZI](https://www.st.com/en/microcontrollers-microprocessors/stm32h753zi.html) and [NUCLEO-H753ZI](https://www.st.com/en/evaluation-tools/nucleo-h753zi.html).

### FreeRTOS

On the ARM builds (steps 2 and 3) we use FreeRTOS with three tasks:

| Task | Priority | Job |
| --- | --- | --- |
| Sensor | High | Reads the sensors at a fixed rate and adds a timestamp |
| Flight | Medium | Checks the readings and decides what the rocket is doing |
| Telemetry | Low | Sends data over the radio and saves it to the flight log |

```text
Sensor task --queue--> Flight task --queue--> Telemetry task
```

The flight logic itself does not use FreeRTOS, so it still runs on the PC.

#### Why a FreeRTOS queue between the tasks

A [FreeRTOS queue](https://freertos.org/Documentation/02-Kernel/02-Kernel-features/02-Queues-mutexes-and-semaphores/01-Queues) is a safe way to send data from one task to another. The sender puts a message in, the receiver takes it out, first in, first out.

| Why it fits us | Explanation |
| --- | --- |
| **No shared variables** | Each task owns its data. Two tasks never read and write the same variable at the same time, so we avoid a whole class of hard-to-find bugs. |
| **Safe by design** | The queue handles the locking. We do not write our own. |
| **The message is copied** | A queue copies the message in. The sensor task can start the next cycle right away, and the flight task has its own copy that nobody changes. One message holds all readings and **one timestamp**, so they always belong together. |
| **The receiver can wait** | The flight task can sleep until a message arrives, so it does not waste CPU. We can set a **timeout**, so if the sensor task stops sending, the flight task notices and does not hang. |
| **Slow work stays away from the important work** | The sensor task is fast and exact. The radio and flash log are slow. The queue between flight and telemetry means the slow telemetry task never delays the flight task. |
| **Full queue = our choice** | If the telemetry queue is full, the flight task can drop the message and keep flying. |
| **Simple to test** | Tasks only know their input and output queue. We can test the flight logic on the PC by feeding it messages, with no hardware. |
| **Small and built in** | It is part of the FreeRTOS kernel, so there is nothing extra to install. |

#### Minimal example

This is only an illustration. It is not in the project yet. The sensor task sends one message, the flight task receives it.

```cpp
#include "FreeRTOS.h"
#include "queue.h"

struct SensorMessage {
    Reading altitude;
    Reading velocity;
    TickType_t timestamp;   // one timestamp for all readings
};

QueueHandle_t sensorQueue = xQueueCreate(8, sizeof(SensorMessage));   // holds up to 8 messages

// Sensor task: send a message every 10 ms
void sensorTask(void*) {
    while (true) {
        SensorMessage msg = {altitude.read(), velocity.read(), xTaskGetTickCount()};
        xQueueSend(sensorQueue, &msg, 0);    // 0 = do not wait if the queue is full
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}

// Flight task: wait up to 50 ms for a message
void flightTask(void*) {
    while (true) {
        SensorMessage msg;
        if (xQueueReceive(sensorQueue, &msg, pdMS_TO_TICKS(50)) == pdTRUE) {
            // use msg, but check msg.altitude.valid first
        } else {
            // timeout: no data for 50 ms, treat the sensors as failed
        }
    }
}
```

### Renode (step 2)

Renode has a model of our board, so we can run the ARM build without hardware. Limits:

- Sensors are not part of the board model, so Renode runs our **simulated** sensors.
- That means it does **not** test real I2C/SPI sensor drivers. Only the real board (step 3) can.
- We have not run any firmware in Renode yet.

Source: [Renode supported boards](https://renode.readthedocs.io/en/latest/introduction/supported-boards.html).
