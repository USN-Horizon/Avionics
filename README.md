<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="https://raw.githubusercontent.com/USN-Horizon/.github/main/profile/assets/USNHorizonLogoLight.png">
  <img
    alt="USN Horizon"
    src="https://raw.githubusercontent.com/USN-Horizon/.github/main/profile/assets/USNHorizonLogoDark.png"
    width="200">
</picture>

# Avionics

Flight computers, ground station, telemetry and simulation for USN Horizon's rockets.

The avionics team designs the electronics and software that fly inside the rocket, and the systems that follow it from the ground. For EuRoC 2027 that means our own flight computer, a ground station, the telemetry link between them, and a hardware in the loop (HIL) setup that tests the flight software against simulated flights before it ever leaves the ground.

## What we build

| System | What it does |
| --- | --- |
| **Flight computer** | Our own SRAD flight computer. Reads the sensors, tracks the flight state, deploys recovery and sends telemetry. A CATS Vega flies alongside it as an independent backup with its own battery. |
| **Ground station** | A station in a hard case, with its radio on a tripod. Talks to the rocket over radio, logs every flight and serves live data to the team's laptops and phones at the launch site. |
| **Simulation** | Runs the flight software against simulated flights, so the code is tested long before it flies. |

## Repository structure

```text
Avionics/
├── hardware/
│   ├── flight-computer/    Flight computer PCB design
│   └── ground-station/     Ground station PCB design and case
├── software/
│   ├── flight-computer/    Flight firmware
│   ├── ground-station/     Telemetry receiver, logging and live view
│   └── simulation/         Hardware in the loop and flight simulation
├── testing/                Test vehicles and test rigs, such as the Avionics Testing Rocket
├── docs/                   Avionics wiki: how everything works and how to use it
└── archived/               Earlier projects (2024 to 2026), kept for reference
```

Every folder has its own README explaining what belongs there.

## Tech stack

| Area | Tools |
| --- | --- |
| PCB design and wiring | Altium Designer and KiCad for PCBs, E3.series for wiring |
| Flight computer | STM32H753, with an STM32WLE5 for the LoRa radio link |
| Flight firmware | C++ on FreeRTOS, built with PlatformIO |
| Ground station | Raspberry Pi 5 with a Python (FastAPI) web server and a browser interface in HTML, CSS and JavaScript |

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before your first pull request. All work happens on a branch and reaches `main` through a reviewed pull request.

## Links

[Avionics wiki](docs/README.md) · [Horizon wiki](https://wiki.usnhorizon.no/) · [usnhorizon.no](https://usnhorizon.no/) · [avionics@usnhorizon.no](mailto:avionics@usnhorizon.no)
