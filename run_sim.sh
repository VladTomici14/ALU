#!/bin/bash 

# compiling the code
iverilog -g2012 -o alu_sim alu_8bit.sv tb_alu.sv

# running the simulation 
vvp alu_sim 

# cleaning up 
# rm -rf alu_sim
