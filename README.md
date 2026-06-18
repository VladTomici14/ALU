# ALU Project

We're using **SystemVerilog** with **iverilog v12** for full SystemVerilog support.

## Team Tasks

- **Addition, Subtraction, Multiplication** (Christian)
- **Division, AND, OR, XOR, Left Shift, Right Shift** (Tomici)

## In order to run CLI -> ./run_cli.sh - also, update usage on alu_8bit vs alu_8bit_top

## Project Structure

```
.
├── alu_8bit.sv          # Main ALU module
├── alu_8bit_top.sv      # Top module/wrapper
├── tb_alu.sv            # Testbench
├── operations/          # Reference operation modules
├── build/               # Compiled simulation binaries (generated)
├── sim/                 # Simulation outputs (VCD, logs) (generated)
├── Makefile             # Build and simulation control
├── Dockerfile           # Ubuntu 20.04 simulation environment
└── README.md
```

## Building and Running

### Using Make

```bash
# Compile and run simulation
make all

# Run specific testbench
make tb_alu

# Clean build artifacts
make clean
```

### Using Make with Docker

```bash
# Build the Docker image
docker build -t alu-sim .

# Run the container
docker run --rm alu-sim
```

### Manual Compilation (if needed)

```bash
# Compile the code 
iverilog -g2012 -o build/alu_sim alu_8bit.sv tb_alu.sv

# Run the simulation 
vvp build/alu_sim

# View the waveform
gtkwave sim/dump.vcd
```

## Output Files

After running `make all`:
- `build/tb_alu.out` - Compiled simulation executable
- `sim/tb_alu.log` - Simulation output log
- `sim/dump.vcd` - GTKWave waveform file

This will compile and run the simulation inside the container. The `dump.vcd` file will be generated in the container, but since it's ephemeral, you might want to mount a volume or copy it out.

To view the waveform, you can copy the `dump.vcd` from the container or run gtkwave on your host if you have it installed.