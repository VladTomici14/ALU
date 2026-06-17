IVERILOG := iverilog
VVP := vvp

IVERILOG_FLAGS := -Wall -g2012
VVP_FLAGS := -v -l sim/log

BUILD_DIR := build
VCD_DIR := sim

# ALU sources
RTL_SOURCES := alu_8bit.sv alu_8bit_top.sv
TESTBENCHES := tb_alu

.PHONY: all clean docker
all: prepare $(TESTBENCHES)

prepare:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(VCD_DIR)

$(BUILD_DIR)/%.out: %.sv $(RTL_SOURCES) | prepare
	@echo "Compiling $< -> $@"
	$(IVERILOG) $(IVERILOG_FLAGS) -s $(*F) -o $@ $(RTL_SOURCES) $<

run_%: $(BUILD_DIR)/%.out
	@echo "Running $(*F)"
	$(VVP) $< $(VVP_FLAGS) > $(VCD_DIR)/$*.log
	@if [ -f dump.vcd ]; then mv dump.vcd $(VCD_DIR)/; fi

$(TESTBENCHES): %: run_%

docker:
	docker build -t alu-sim .
	docker run --rm alu-sim

clean:
	rm -rf $(BUILD_DIR) $(VCD_DIR)
