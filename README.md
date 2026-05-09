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

## Running with Docker

To run the simulation in a Docker container:

1. Build the Docker image:
```bash
docker build -t alu-sim .
```

2. Run the container:
```bash
docker run --rm alu-sim
```

This will compile and run the simulation inside the container. The `dump.vcd` file will be generated in the container, but since it's ephemeral, you might want to mount a volume or copy it out.

To view the waveform, you can copy the `dump.vcd` from the container or run gtkwave on your host if you have it installed.