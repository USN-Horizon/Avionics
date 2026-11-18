# radio-module
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



Instructions for windows and VScode:
- install the IDE platformio
- install ST-LINK here "https://www.st.com/en/development-tools/stsw-link009.html"
- to unlock the write pins if it is a fresh board, "https://www.st.com/en/development-tools/stm32cubeprog.html"
- install drivers to let windows read coms "https://www.silabs.com/software-and-tools/usb-to-uart-bridge-vcp-drivers?tab=downloads"


How to initialize the boards:
First we need to unlock the boards as they come locked from the factory. We need to use the stm32 programmer and boot it into under reset mode, we connect and move over to OB where we set the mode to AA (0).

We use the platformio.ini ide integration with vscode to build, upload, monitor, clean the codebase and chip.

Information about the board and chip/s:
https://wiki.seeedstudio.com/LoRa_E5_mini/#applications-1