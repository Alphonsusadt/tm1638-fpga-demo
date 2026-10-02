# TM1638 UTS - synthesize complete demo
# Uses tcl/top_tm1638_demo.v + tcl/tm1638.v

yosys -import

set top_level "top_tm1638_demo"
set src_files [list "top_tm1638_demo.v" "tm1638.v"]

foreach file $src_files {
    puts "Parsing source file: tcl/$file"
    read_verilog tcl/$file
}

read_verilog -lib +/ice40/cells_sim.v
hierarchy -check -top $top_level
yosys proc
synth_ice40 -top $top_level -json "build/${top_level}_netlist.json"

stat
write_verilog "build/${top_level}_netlist.v"
write_verilog -noattr "build/${top_level}_netlist_noattr.v"

puts "Done: build/${top_level}_netlist.json"
