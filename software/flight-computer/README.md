# Flight Computer
## Build instructions
[Install platformIO Core (CLI) or IDE](https://platformio.org/install)

If using platformIO Core: \
`pio run` is used to build the project. \
`pio run -t upload` is used to program the connected microcontroller.

## Troubleshooting
### Upload issues
To upload the flight computer on the f411ce,
it needs to be in DFU mode.
To set it to DFU mode, hold down the BOOT0 button while it resets
(you can for example hold the BOOT0 down, and then press NRST button).

On windows, the DFU drivers might not be installed.
You can use winget to install zadig and run zadig to install the driver.

## Vendored FreeRTOS
The files under lib/FreeRTOS and FreeRTOS-ports have been extracted from FreeRTOS 202604.01 (LTS)
A copy of the used port is in lib/FreeRTOS/portable/GCC.
(multiple ports cannot be included at the same time, since platformio compiles everything in the lib directory)
Could possibly write a script which copies the correct port into lib before build time?
If we want to build for multiple platforms

### FreeRTOS notes
The FreeRTOS cortex-M4F port must be built
using hardware floating point support
https://docs.freertos.org/Documentation/02-Kernel/03-Supported-devices/04-Demos/ST-Microelectronics/FreeRTOS-for-STM32F4xx-Cortex-M4F-IAR

always #include <FreeRTOS.h> first in source files. (if using FreeRTOS functions)
and then include any of
* task.h
* queue.h
* semphr.h
* timers.h
* event_groups.h
* stream_buffer.h
* message_buffer.h
do not include any other freertos headers.
