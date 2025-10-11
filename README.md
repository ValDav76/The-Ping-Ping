**Welcome on the Ping Ping project 🤘**

![81f3b7a4-b5e5-414a-a2e0-19aac4d8ec19](https://github.com/user-attachments/assets/5925cfe0-8dbd-4eca-8838-674eccd27444)


A fully digital guitar effects pedal built entirely with FPGA logic.

**Overview**

This project aims to design a fully digital guitar effects pedal implemented on an FPGA, without any external CPU.

All audio processing is performed in real time using custom hardware blocks written in VHDL/Verilog, and connected through standard interfaces like I²S, AXI Stream, and Wishbone.

**Features**

🎛️ Distortion effect implemented using an arctangent function, approximated via lookup tables (LUTs) and linear interpolation

🔊 Custom I²S interfaces:

I²S → AXI Stream and AXI Stream → I²S

Includes full serial/parallel and parallel/serial conversion

🧪 Simulation and verification with Cocotb testbenches for each module

🧩 I²C ↔ Wishbone bridge for codec initialization and control register access

🎚️ Digital FIR filter (in progress) for low-pass and high-pass filtering

🧾 Custom PCB design, first prototype tested (minor hardware adjustments planned)


**Work in Progress**

 []  Finalize and test the new PCB revision

 []  Integrate the FIR filter into the main audio processing chain

 []  Add real-time effect parameter control via I²C

 []  Implement additional effects (e.g., reverb, delay, EQ


 0
