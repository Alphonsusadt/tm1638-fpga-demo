# TM1638 low-level byte driver synthesis/check

yosys -import

set top_level "tm1638"
set src_file "tcl/tm1638.v"

puts "Parsing source file: $src_file"
read_verilog $src_file

hierarchy -check -top $top_level
yosys proc
synth -top $top_level

stat
write_verilog "build/${top_level}_netlist.v"
write_verilog -noattr "build/${top_level}_netlist_noattr.v"

puts "TM1638 driver check complete."
