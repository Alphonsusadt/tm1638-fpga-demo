DIR_BUILD = build
DIR_CONS = constraints
DIR_RTL = rtl
DIR_SIM = sim
DIR_TB = tb
DIR_TCL = tcl

TOP_LEVEL = basic
VERILOGS = $(DIR_RTL)/tm1638.v $(DIR_RTL)/basic.v

compile:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	iverilog \
    -o $(DIR_BUILD)/$(TOP_LEVEL)_sim \
    $(VERILOGS) \
    $(DIR_TB)/tm1638_tb.v

vvp:
	vvp $(DIR_BUILD)/$(TOP_LEVEL)_sim +vcd=$(DIR_BUILD)/tm1638_tb.vcd

gtk:
	gtkwave $(DIR_BUILD)/tm1638_tb.vcd

sim:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	iverilog -o $(DIR_BUILD)/$(TOP_LEVEL)_sim $(VERILOGS) $(DIR_TB)/tm1638_tb.v
	vvp $(DIR_BUILD)/$(TOP_LEVEL)_sim +vcd=$(DIR_BUILD)/tm1638_tb.vcd
	gtkwave $(DIR_BUILD)/tm1638_tb.vcd


syn:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	yosys -p "synth_ice40 -top top -json $(DIR_BUILD)/$(TOP_LEVEL)_netlist.json" $(VERILOGS)

pnr:
	nextpnr-ice40 \
		--up5k \
		--package sg48 \
		--json $(DIR_BUILD)/$(TOP_LEVEL)_netlist.json \
		--pcf $(DIR_CONS)/TM1638.pcf \
		--asc $(DIR_BUILD)/$(TOP_LEVEL).asc

bit:
	icepack $(DIR_BUILD)/$(TOP_LEVEL).asc $(DIR_BUILD)/$(TOP_LEVEL).bin

flash:
	icesprog $(DIR_BUILD)/$(TOP_LEVEL).bin

all:
	if not exist $(DIR_BUILD) mkdir $(DIR_BUILD)
	yosys -p "synth_ice40 -top top -json $(DIR_BUILD)/$(TOP_LEVEL)_netlist.json" $(VERILOGS)
	nextpnr-ice40 \
		--up5k \
		--package sg48 \
		--json $(DIR_BUILD)/$(TOP_LEVEL)_netlist.json \
		--pcf $(DIR_CONS)/TM1638.pcf \
		--asc $(DIR_BUILD)/$(TOP_LEVEL).asc
	icepack $(DIR_BUILD)/$(TOP_LEVEL).asc $(DIR_BUILD)/$(TOP_LEVEL).bin

clean:
	if exist $(DIR_BUILD) rmdir $(DIR_BUILD) /S /Q
