# axi4_bram_controller_verifi
This is a working project to verifiy AXI4 Interconnect Matrix.
Step 1: Verify an in-order AXI4 BRAM Controller. 

-----------------------------
UPDATES
-----------------------------
8_24_2026: Committed working base sequence. Random sequence is in process of verification. <br/> 

-----------------------------
AXI4 BRAM Controller Verification Environment
-----------------------------
A UVM-based verification IP (VIP) built to validate an AXI4 memory-mapped slave, Xilinx's AXI BRAM Controller (PG078), using a SystemVerilog OOP testbench, a C++/DPI reference-model scoreboard, and embedded protocol assertions. This is the first milestone toward a larger goal: verifying a full multi-channel AXI4 interconnect. <br/> 

-----------------------------
OVERVIEW
-----------------------------
* The DUT is an AXI4 BRAM Controller (axi_bram_ctrl_0, generated from Xilinx IP catalog PG078) wrapped in a custom RTL block and driven through a UVM 1.2 environment. Every transaction is checked two ways: SystemVerilog Assertions catch protocol-level handshake violations in real time, while a C++ DPI-based scoreboard independently models the memory and verifies write/read data correctness per transaction ID. The environment runs under AMD Vivado Simulator (XSim) 2026.1, co-simulating SystemVerilog, the IP's VHDL netlist, and a SystemC/C++ DPI scoreboard in a single mixed-language flow. <br/> 

* This project starts by verifying a single AXI4 slave first, so the agent/env/scoreboard architecture can be proven correct and reused when the interconnect-level DUT comes online. <br/> 

-----------------------------
GOALS
-----------------------------
* The handshake protocol where every channel (AW, W, B, AR, R) holds to AMBA AXI4 rules must be finalized. Once VALID asserts, it and the associated payload must not change until READY responds. <br/> 
* The write and read data must be independently verified against a reference model, facilitated by transaction ID (AWID/ARID). <br/> 
* As  Xilinx's BRAM Controller is a VHDL/SystemC model under the hood, consideration was put into the UVM, SystemVerilog, VHDL, and a C++/DPI scoreboard to reliably co-simulate in XSim. <br/> 
* I made the structure of the agent, sequences, environment, and scoreboard so that scaling from one AXI4 slave to a multi-master, multi-slave interconnect is a seamless additive process. <br/> 

-----------------------------
KEY ACHIEVEMENTS
-----------------------------
* I built a complete UVM 1.2 environment including agent (driver, monitor, sequencer), environment, scoreboard, sequence library, and base test around a real AXI4 slave IP rather than a behavioral stub. <br/> 
* I implemented a C++/DPI-C reference-model scoreboard that mirrors the addressable memory in a hash map and validates read data using per-ID FIFOs (pending_reads[id]), so read responses are checked correctly by transaction ID rather than assumed to arrive in issue order. This will be the basis for the out-of-order matching at the interconnect level later. <br/> 
* I embedded SystemVerilog Assertions directly in the AXI4 interface (axi4_if) covering AWVALID/WVALID payload stability and address-channel deadlock detection, so every test automatically inherits protocol checking without extra wiring. <br/> 
* I got a full mixed-language simulation working: SystemVerilog testbench + Xilinx's VHDL BRAM Controller netlist and a SystemC/C++ DPI scoreboard, compiled and elaborated together cleanly under Vivado XSim.
* I diagnosed and fixed a Windows-specific DLL-loading crash in the SystemC/DPI runtime by correctly scoping Vivado's xsc linker properties (xsim.elaborate.xsc.more_options), which is a non-obvious toolchain issue that broke the simulation launch. <br/> 

-----------------------------
VERIFICATION STRATEGY
-----------------------------
* UVM class hierarchy: axi4_agent (driver + monitor + sequencer) feeds axi4_env, which connects to axi4_scoreboard via an analysis port; stimulus comes from a base sequence and a burst sequence for multi-beat INCR/WRAP traffic. <br/> 
* The scoreboarding integration was in C++. I pushed the write data into a software memory model on the write channel, and checked the read data against it on the read channel using ID-indexed queues, so the design is ready to validate responses that arrive out of order. <br/> 
* Handshake stability and stall/deadlock timeouts are enforced identically across every test that instantiates the interface as protocol compliance via SVA resides in a shared interface.
* The target simulator is the AMD Vivado Simulator (XSim) 2026.1, mixed-language (SystemVerilog + VHDL) with SystemC-based DPI co-simulation for the scoreboard. <br/> 

-----------------------------
ROADMAP
-----------------------------
* Scale the DUT from a single AXI4 BRAM Controller to the full 5-channel AXI4 Interconnect Matrix, with multiple masters arbitrating for shared memory. <br/> 
* Extend the scoreboard's per-ID matching (already in place for the BRAM controller's read channel) into concurrent out-of-order verification across multiple interleaved masters. <br/> 
* Add Read-After-Write (RAW) hazard checking where a read can land on an address with a write still in flight through the interconnect pipeline. <br/> 
* Build dedicated stress tests that can hold READY low for 50–100+ cycles under continuous VALID traffic and confirm zero FIFO overflow, zero dropped beats, zero state-machine deadlock.
* Add 4KB burst-boundary crossing tests to confirm the assertion layer flags them before they reach memory.
* Implement functional coverage crossing burst type (INCR/WRAP), backpressure delay bucket, and channel state, targeting full coverage closure.
* Write a formal verification plan document mapping each hazard to a Feature ID (e.g. FEAT_01_HANDSHAKE, FEAT_02_OOO_MATCH) for traceability from spec to test.
* Add seed sweeps, scoreboard log, and exported coverage summary.

-----------------------------
REFERENCES
-----------------------------
ARM AMBA AXI and ACE Protocol Specification: Primary specification for Memory-Mapped AXI4 (Doc ID: ARM IHI 0022). <br/>   
AMD Xilinx AXI BRAM Controller: Product Guide (PG078). <br/>  
Xilinx AXI Protocol Checker: Product Guide for SVA definitions (PG101). <br/> 
