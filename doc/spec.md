---
lang: "en"
font: "Times New Roman"
documentclass: extarticle
classoption:
    - titlepage
indent: true
linestretch: 1.25
date: \today
title: "**Project documentation**"
subtitle: "\"Specification\""
author:
    - "Markidonov Vladimir"
    - "Kutsenko Artyom"
    - "Volk Alexander"
fontsize: 14pt
colorlinks: true
header-includes: |
    \usepackage{indentfirst}
    \onehalfspacing
    \hyphenpenalty=10000
---


## Contents

0. [Glossary](#glossary)

1. [Introduction](#introduction)

1.1 [Summary](#introduction-summary)

1.2 [Scope](#introduction-scope)

2. [System overview and requirements](#system)

2.1 [Overview](#system-overview)

2.2 [User interface/controls](#system-ui-controls)

2.3 [Gameplay](#system-gameplay)

3. [Hardware](#hardware)

3.1 [Components](#hardware-components)

3.2 [Communication Protocols](#hardware-communication-protocols)

3.3 [Hardware/schematics requirements](#hardware-requirements)

4. [Software](#software)

4.1 [Software requirements](#software-requirements)

5. [Project files](#files)

6 [Appendix](#appendix)

\newpage

## Glossary {#glossary}

- [**Game unit**]{#glossary-unit} - also called just **unit** or **system** interchangeably; 
Electronic device or a schematics model and its operating software that are implementing this specification.
- [**Main program**]{#glossary-main-program} - machine program that runs by system's CPU.
- [**Controller**]{#glossary-controller} - a set of hardware components used to operate a game unit as a user.
- [**Main display**]{#glossary-main-display} - output display that presents game to the player.
- [**Player**]{#glossary-player} - user operating device with controller.
- [**HP (Health Points) counter**, **Player score counter** and **Bot score counter**]{#glossary-counters} - integer counters used in gameplay. 
- [**AI**]{#glossary-ai} - components that interact with the gameplay that are fully operated by the system. 
- [**Lose condition**  and **Win condition**]{#glossary-end-conditions} - logic conditions used to determine when a game ended either with a loss or win for the player. 

\newpage

## 1. Introduction {#introduction}

### 1.1 Summary {#introduction-summary}

Project goal is to develop  video-game device - [game unit](#glossary-unit), based on shoot 'em up video-game ["Space Invaders"](https://en.wikipedia.org/wiki/Space_Invaders) using educational hardware simulator and design tool `Logisim` and utilizing `CDM-16` processor available as third-party module.

### 1.2 Scope {#introduction-scope}

Specification's scope is confined to defining functional requirements for the system's operation,
means of interacting with system, and describing basic design principals on which hardware and software should be built.

Design and implementation decisions that aren't explicate in this document are left to developers. Therefore specification outlines following:

- Hardware: CPU, Hardware communication protocol, User interface hardware.
- Software: [Main program](#glossary-main-program) architecture and design principals.

\newpage

## 2. System overview and requirements {#system}

### 2.1 Overview {#system-overview}

Game unit as application-specific computational device is based around general-purpose Harvard architecture `CDM-16` processor that executes main program,
and peripherals such as memory, user-interface hardware,
and application-specific circuits for special computations.

All system's hardware schematics is developed in `Logisim` software tool.
System's software is a program for `CDM-16` ISA.

The game rules differs from classic **1978 "Space Invaders"**. Firstly there is less enemies, but player doesn't have defense bunkers or walls protecting them from enemy's bullets. More importantly player has now additional task to score more kills than his AI "opponent" that is also shooting at invading aliens. 

### 2.2 User interface/controls {#system-ui-controls}

- User interact with system via [controller](#glossary-controller) that consist of 3 buttons: `left`, `right`, `shoot`. 
- Unit displays game (game state presented in suitable way) on [main display](#glossary-main-display) and additional indicators for [HP and score counters](#glossary-counters).
- Main display is monochrome with resolution of 32x32 pixels.
- All game's entities are distinguishable either by their unique placement, moving pattern or definite graphical representation.

### 2.3 Gameplay {#system-gameplay}

- At the start the game spawns the *enemy* grid consisting of 3 rows of 5 enemies at the very top of the display.
- Each enemy is 3x3 pixels entity and has its own placement in the grid.
- All enemies can shoot visible projectile *bullets* that move downwards in a straight line.
- No more than 2 enemy bullets can exist at the same time
- Enemy grid moves as a whole from one display edge to another horizontally and shifts down after touching an edge.
- 1 pixel above the very bottom of the display 2 *ships* spawn.
- Ships are distinguishable 3x3 pixels entities.
- Ships can only move horizontally from one display edge to the other.
- One of the ships is controlled by the [player](#glossary-player) via [controller](#glossary-controller) accordingly.
- Other ship is controlled by [AI](#glossary-ai)
- Pressing `shoot` controller button shoots visible *bullet* from position of player controlled ship.
- Similarly, AI controlled ship can also shoot from its position.
- Only 1 bullet from each corresponding ship can exist at a time.
- When ship bullet collides with enemy, enemy gets *eliminated* and its place in grid remains empty while the bullet itself destructs.
- If player ship's bullet eliminate enemy, [`Player score counter`](#glossary-counters) increments, correspondingly `Bot score counter` increments when AI ship's bullet kills enemy.
- When enemy bullet hits player ship, [`Health points counter`](#glossary-counters) decrements.
- AI ship doesn't take any damage and cannot be eliminated.
- Any enemy or ship bullet that reach display's out of bounds despawns.
- `HP counter` = 0 OR *enemy grid approached ship's plane* is the [**Lose condition**](#glossary-end-conditions).
- To win, player must score more kills than the AI ship; therefore: 
- - *All enemies are eliminated* AND `Player score counter` > `Bot score counter` is the [**Win condition**](#glossary-end-conditions)
- - while *All enemies are eliminated* AND `Player score counter` **<** `Bot score counter` is still **Lose condition**.

\newpage

## 3. Hardware {#hardware}

### 3.1 Components {#hardware-components}

- [Controller](#glossary-controller) as described in [2.2](#system-gameplay) is implemented via standard `Logisim` button components.
- [Main display](#glossary-main-display) implemented as 32x32 LED Matrix that renders from *video buffer circuit*.
- [Gameplay counters](#glossary-counters) are shown on standard seven-segment digit displays.
- System's computational circuitry is based on `CDM-16` processor core built on Harvard architecture that runs *main program*.
- System have additional application-specific components for special computations, data manipulation, data transfer, etc.
- System utilize hardware rendering, main processor only sends data to special rendering components thats communicate with *video-buffer*.

### 3.2 Communication Protocols {#hardware-communication-protocols}

- Communication between CPU and peripheral hardware components is conducted via *memory mapped I/O* mechanism.

### 3.3 Hardware/schematics requirements {#hardware-requirements}

- All system's hardware schematics must be accessible as `.circ` `Logisim` project file in `hardware` directory.
- Naturally, system is constrained by `Logisim` simulator capabilities, mainly it is manageable size of schematics, amount of components and tick frequency of 4.1 KHz *max*.
- System must be *stable* and *deterministic*, system's behavior must be predictable under change of clock signal and other input parameters.
- Schematics should be readable and appropriately labeled.

\newpage

## 4. Software {#software}

### 4.1 Software requirements {#software-requirements}

- Program contains *check loop*, where it checks program state, collects data from and sends to peripherals and additional computational devices, then proceeds to compute next state of the game.
- Program collects data via *polling*.
- Source code of the [main program](#glossary-main-program) is written in CDM-16 assembly language that can be assembled by standard [`cdm-devkit`](https://github.com/cdm-processors/cdm-devkit).
- Source code should be commented and readable. 
- All program source code is available in `software` directory.

## 5. Project files {#files}

All project files are accessible in git repository on GitHub. Layout for software and hardware parts is as described in corresponding sections [4.1](#software-requirements) and [3.3](#hardware-requirements). 

All documentations files (including this specification) are available in `docs` directory.

\newpage

## 6. Appendix {#appendix}

References:

- [Original Space Invaders source code](http://computerarcheology.com/Arcade/SpaceInvaders/Code.html)
- [`CDM Processors` documentation](https://github.com/cdm-processors/cdm-devkit/tree/master/docs)
- A.Shafarenko and S.P.Hunt, Computing platforms

Materials:

- [`Logisim` simulation tool](https://www.cburch.com/logisim)
- [`CDM Processors` development kit](https://github.com/cdm-processors/cdm-devkit)
- [Project's `GitHub` repository](https://github.com/MDdev-studio/space-invaders)
