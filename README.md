# ALU Project
We're gonna use *SystemVerilog*.

## Impartire operatii 

Christian 
- Multiplication
- Addition
- Subtraction

Tomici
- Division 
- AND
- OR 
- XOR
- LEFT SHIFT
- RIGHT SHIFT


## How to run depending 

1. Compile the code 
```bash
iverilog -g2012 -o alu_sim alu_8bit.sv tb_alu.sv
```

2. Run the simulation 
```bash
vvp alu_sim
```

3. View the waveform 
```bash 
gtkwave dump.vcd
```