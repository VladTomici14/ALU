IVERILOG := iverilog
VVP := vvp

IVERILOG_FLAGS := -Wall -g2012
VVP_FLAGS := -v -l sim/log

BUILD_DIR := build
VCD_DIR := sim

# ALU sources
RTL_SOURCES := alu_8bit.sv alu_8bit_top.sv $(wildcard operations/*.sv)
TESTBENCHES := tb_alu tb_alu_top

.PHONY: all clean docker cli
all: prepare $(TESTBENCHES)

$(BUILD_DIR)/tb_alu_cli.out: tb_alu_cli.sv $(RTL_SOURCES) | prepare
	@echo "Compiling $< -> $@"
	$(IVERILOG) $(IVERILOG_FLAGS) -s tb_alu_cli -o $@ $(RTL_SOURCES) $<

cli: $(BUILD_DIR)/tb_alu_cli.out

prepare:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(VCD_DIR)

$(BUILD_DIR)/%.out: %.sv $(RTL_SOURCES) | prepare
	@echo "Compiling $< -> $@"
	$(IVERILOG) $(IVERILOG_FLAGS) -s $(*F) -o $@ $(RTL_SOURCES) $<

run_%: $(BUILD_DIR)/%.out
	@echo "Running $(*F)"
	$(VVP) $< $(VVP_FLAGS) > $(VCD_DIR)/$*.log
	@if [ -f $*.vcd ]; then mv $*.vcd $(VCD_DIR)/; fi

$(TESTBENCHES): %: run_%

docker:
	docker build -t alu-sim .
	docker run --rm alu-sim

clean:
	rm -rf $(BUILD_DIR) $(VCD_DIR)