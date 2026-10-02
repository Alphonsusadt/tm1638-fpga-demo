# Build scaffold adapted from arumdapta98/oss-cad-suite-tcl-template.
# Verilog sources are in tcl as explicitly required by the assignment slide.
DIR_BUILD = build
DIR_CONS = constraints
DIR_RTL = rtl
DIR_SIM = sim
DIR_TB = tb
DIR_TCL = tcl

TOP_LEVEL = top_tm1638_demo
VERILOGS = $(DIR_TCL)/tm1638.v $(DIR_TCL)/top_tm1638_demo.v
ICE40_CELLS ?= D:/tools/oss-cad-suite/share/yosys/ice40/cells_sim.v

.PHONY: verify test test-production test-netlist compile vvp gtk sim syn pnr bit flash all clean

verify:
	$(MAKE) test
	$(MAKE) test-production
	$(MAKE) test-netlist
	$(MAKE) all

test-netlist:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	yosys -c $(DIR_TCL)/top_tm1638_demo.tcl
	iverilog -g2012 -DNO_ICE40_DEFAULT_ASSIGNMENTS -s startup_netlist_tb -o $(DIR_BUILD)/startup_netlist_tb.vvp $(DIR_BUILD)/$(TOP_LEVEL)_netlist_noattr.v $(DIR_TB)/startup_netlist_tb.v $(ICE40_CELLS)
	vvp $(DIR_BUILD)/startup_netlist_tb.vvp

test-production:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	iverilog -g2012 -DNO_ICE40_DEFAULT_ASSIGNMENTS -s production_clock_tb -o $(DIR_BUILD)/production_clock_tb.vvp $(VERILOGS) $(DIR_TB)/production_clock_tb.v $(ICE40_CELLS)
	vvp $(DIR_BUILD)/production_clock_tb.vvp

test:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	iverilog -g2012 -s driver_check_tb -o $(DIR_BUILD)/driver_check_tb.vvp $(DIR_TCL)/tm1638.v $(DIR_TB)/driver_check_tb.v
	vvp $(DIR_BUILD)/driver_check_tb.vvp
	iverilog -g2012 -DNO_ICE40_DEFAULT_ASSIGNMENTS -s scroll_tb -o $(DIR_BUILD)/scroll_tb.vvp $(VERILOGS) $(DIR_TB)/scroll_tb.v $(ICE40_CELLS)
	vvp $(DIR_BUILD)/scroll_tb.vvp
	iverilog -g2012 -DNO_ICE40_DEFAULT_ASSIGNMENTS -s system_check_tb -o $(DIR_BUILD)/system_check_tb.vvp $(VERILOGS) $(DIR_TB)/system_check_tb.v $(ICE40_CELLS)
	vvp $(DIR_BUILD)/system_check_tb.vvp

compile:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	iverilog \
    -s tm1638_tb \
    -o $(DIR_BUILD)/$(TOP_LEVEL)_sim \
    $(VERILOGS) \
    $(DIR_TB)/tm1638_tb.v

vvp:
	vvp $(DIR_BUILD)/$(TOP_LEVEL)_sim +vcd=$(DIR_BUILD)/tm1638_tb.vcd

gtk:
	gtkwave $(DIR_BUILD)/tm1638_tb.vcd

sim:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	iverilog -s tm1638_tb -o $(DIR_BUILD)/$(TOP_LEVEL)_sim $(VERILOGS) $(DIR_TB)/tm1638_tb.v
	vvp $(DIR_BUILD)/$(TOP_LEVEL)_sim +vcd=$(DIR_BUILD)/tm1638_tb.vcd
	gtkwave $(DIR_BUILD)/tm1638_tb.vcd


syn:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	yosys -p "synth_ice40 -top $(TOP_LEVEL) -json $(DIR_BUILD)/$(TOP_LEVEL)_netlist.json" $(VERILOGS)

pnr:
	nextpnr-ice40 \
		--up5k \
		--package sg48 \
		--freq 12 \
		--json $(DIR_BUILD)/$(TOP_LEVEL)_netlist.json \
		--pcf $(DIR_CONS)/TM1638.pcf \
		--asc $(DIR_BUILD)/$(TOP_LEVEL).asc

bit:
	icepack $(DIR_BUILD)/$(TOP_LEVEL).asc $(DIR_BUILD)/$(TOP_LEVEL).bin

flash:
	icesprog -w $(DIR_BUILD)/$(TOP_LEVEL).bin

all:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	yosys -p "synth_ice40 -top $(TOP_LEVEL) -json $(DIR_BUILD)/$(TOP_LEVEL)_netlist.json" $(VERILOGS)
	nextpnr-ice40 \
		--up5k \
		--package sg48 \
		--freq 12 \
		--json $(DIR_BUILD)/$(TOP_LEVEL)_netlist.json \
		--pcf $(DIR_CONS)/TM1638.pcf \
		--asc $(DIR_BUILD)/$(TOP_LEVEL).asc
	icepack $(DIR_BUILD)/$(TOP_LEVEL).asc $(DIR_BUILD)/$(TOP_LEVEL).bin

clean:
	if exist $(DIR_BUILD) rmdir $(DIR_BUILD) /S /Q
