# Avionics WIKI
**Authors: Alexander Svarthaugen**

Welcome to USN Horizon's avionics repository for software and hardware. This document gives a structured overview of the whole avionics system and works as a look-up manual for all the documentation and resources the project needs. If you are looking for something specific, go to the [table of contents](#table-of-contents).

Members who want to add to the wiki should read the [documentation standard](#documentation-standard) and the [contributing to the wiki](#contributing-to-the-wiki) section.
The wiki is still under development. Report anything wrong or out of date when you find it, so the documentation for the project stays good, tidy and accurate.
The avionics team and the avionics lead are responsible for keeping the wiki up to date.

## Table of contents
- [System description](#system-description)
    - [Wiring diagram](#wiring-diagram) #Missing
    - [Coordinate system](#coordinate-system) #Missing
    - [Flight states](#flight-states) #Missing
- [Components](#components)
    - [SRAD flight computer](#srad-flight-computer)
    - [CATS Vega](#cats-vega)
    - [Magnetic switch](#magnetic-switch)
    - [Ground station](#ground-station)
- [Hardware](#hardware)
    - [Flight computer board](#flight-computer-board) #Missing
    - [Ground station hardware](#ground-station-hardware) #Missing
- [Software](#software)
    - [Flight computer firmware](#flight-computer-firmware) #Missing
    - [Ground station software](#ground-station-software) #Missing
    - [Simulation](#simulation) #Missing
- [Interfaces](#interfaces)
    - [Telemetry messages](#telemetry-messages) #Missing
- [Procedures](#procedures) #Missing
- [Documentation](#documentation)
    - [Documentation standard](#documentation-standard)
    - [Contributing to the wiki](#contributing-to-the-wiki)

## System description
The avionics is everything electronic that flies in the rocket, and everything that follows it from the ground. For EuRoC 2027 that is our own SRAD flight computer with a CATS Vega as an independent backup, a ground station, the telemetry link between them, and a hardware-in-the-loop (HIL) simulator that tests the flight software against simulated flights before it ever flies.

PCBs are designed in Altium Designer and wiring in E3.series. The flight firmware is written in C++ and runs on FreeRTOS. See the [repository README](../README.md) for how the repository is organized.

### Wiring diagram
#Missing

### Coordinate system
#Missing

### Flight states
#Missing

## Components
### SRAD flight computer
Our own flight computer, designed by the team for EuRoC 2027. It reads the sensors, tracks the flight state, deploys recovery and sends telemetry to the ground station.

### CATS Vega
A COTS flight computer that flies alongside the SRAD flight computer as an independent backup, with its own battery. We have two, with antennas. The configurations used on Ratatoskr are in [archived/2025-2026-ratatoskr/Ratatoskr-CATS-Vega-configurations](../archived/2025-2026-ratatoskr/Ratatoskr-CATS-Vega-configurations/).

### Magnetic switch
Turns the avionics on from outside the rocket, without opening it. We have two COTS magnetic switches from Apogee, and our own design is at the concept stage.

### Ground station
A self-contained station in a hard case. It receives telemetry, logs every flight and shows live data to the team at the launch site.

## Hardware
### Flight computer board
#Missing

### Ground station hardware
#Missing

## Software
### Flight computer firmware
#Missing

### Ground station software
#Missing

### Simulation
#Missing

## Interfaces
### Telemetry messages
#Missing

## Procedures
#Missing

## Documentation
### Documentation standard
Work must be documented in the set format once a board, program or component is taken into use. Write the documentation as if the reader has no earlier insight into how your board or code works, but understands the basics of the tools and languages (C/C++, Git, reading a schematic).

Below is a short checklist of **minimum requirements** for documenting software:
- Inputs and outputs, including message types, with links to [Telemetry messages](#telemetry-messages) where relevant
- Commands or scripts needed to build, flash and run it
- A user and run guide. Describe what someone needs to understand how it works as a whole
- Dependencies. Describe the libraries, toolchain versions and other programs it needs to run

And for hardware:
- Purpose and block diagram
- Connectors and signals (pinout)
- Power: inputs, rails and expected current draw
- Bring-up and test status

Larger parts such as the flight state machine, the telemetry link and the sensor drivers need more thorough documentation, with setup instructions, diagrams, pictures and so on.

As you know, we don't recruit kindergarteners. So write documentation for a reader who knows the basic system, but not your part of it. Basic C/C++ and electronics don't need explaining beyond what comes naturally.

A few more rules:
- Anything not decided or documented yet is marked `#Missing`, both in its section and in the table of contents. Remove the mark when you write the section.
- Update the wiki in the same pull request as the change it describes.
- Put images in `docs/images/` as PNG or SVG. GitHub can't show a PDF inside the page, only link to it. Block diagrams and state machines can be drawn in [Mermaid](https://mermaid.js.org/), which GitHub renders.
- Link to datasheets on the manufacturer's site instead of committing them.
- This repository is public. No prices, sponsor details, personal information or passwords.
- Drafts, meeting notes and work in progress don't go here. Keep them in the task's issue on the avionics project until they are settled.

### Contributing to the wiki
To contribute to the wiki, follow these steps:
1. Do all work in the [Avionics repository](https://github.com/USN-Horizon/Avionics), on a branch, as described in [CONTRIBUTING.md](../CONTRIBUTING.md).
2. Find or add the section in this document that matches the board, program or component you want to document.
3. Write an explanation of what it does in this document, and link to the code or design files you are documenting.
4. Open a pull request. The avionics lead reviews it.

You can make links in .md files like this:
```markdown
[Visible text](#link)
```

> [!IMPORTANT]
> If you have any questions about this document, contact the avionics lead (as of November 2026: **Alexander Svarthaugen**).
