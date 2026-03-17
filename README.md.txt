# 🧠 32-bit RISC Processor (Verilog)

## 📌 Overview

This project implements a **32-bit RISC processor** using Verilog in RTL design style with a pipelined architecture.

## 🔧 Features

* 32 General Purpose Registers (R0–R31)
* R0 = constant zero
* 32-bit Program Counter (PC)
* Word-addressable memory
* No flag registers

## ⚙️ Tools Used

* Intel Quartus Prime (Synthesis)
* ModelSim (Simulation)

## 📚 Instruction Set

* 27 Instructions (R-type & I-type)
* Arithmetic, Logical, Memory, Branching

## 🧪 Testbenches

* ALU Operations
* Factorial Computation

## 📊 Results

* Verified using waveform simulations
* Correct execution of pipeline stages

## 📂 Project Structure

* `src/` → Verilog design files
* `testbench/` → Simulation files
* `docs/` → Reports & diagrams
* `waveforms/` → Output results

## 🚀 How to Run

1. Open ModelSim
2. Compile all Verilog files
3. Run testbench
4. View waveform

## 👨‍💻 Author

Vedant Saxena
