@echo off
set TEST=axi4_base_test

echo Cleaning old files...
rmdir /s /q xsim.dir 2>nul
del /q *.log *.jou *.pb *.so *.dll 2>nul

echo Compiling C++ DPI...
call xsc ..\verif\env\axi4_scoreboard_integration.cpp -o axi_scb

echo Compiling SystemVerilog...
call xvlog -sv -L uvm ..\verif\agent\axi4_agent_pkg.sv
call xvlog -sv -L uvm ..\verif\seq\axi4_seq_pkg.sv
call xvlog -sv -L uvm ..\verif\env\axi4_env_pkg.sv
call xvlog -sv -L uvm ..\verif\tests\axi4_test_pkg.sv
call xvlog -sv -L uvm ..\verif\agent\axi4_interface.sv

call xvlog -sv ..\rtl\ip\axi_bram_ctrl_0\axi_bram_ctrl_0.xci
call xvlog -sv -L uvm ..\rtl\axi4_DUTblock.sv
call xvlog -sv -L uvm ..\verif\axi4_tb.sv

echo Elaborating...
call xelab work.axi4_tb -L uvm -L axi_bram_ctrl_v4_1_14 -L blk_mem_gen_v8_4_13 -sv_lib axi_scb -timescale 1ns/1ps -s top_sim -debug typical

echo Running Simulation...
call xsim top_sim -testplusarg "UVM_TESTNAME=%TEST%" -runall