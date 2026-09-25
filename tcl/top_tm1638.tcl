# ======================================================================
# TM1638 LED Display & Keypad Controller - Synthesis Script
# Using Yosys-Tcl for ice40 FPGA
# ======================================================================

# Initialize the Yosys-Tcl environment
yosys -import

# 1. Define Tcl variables
set top_level "top_tm1638"
set src_files [list "top_tm1638.v" "tm1638.v"]

# 2. Read input RTL files using a Tcl loop
foreach file $src_files {
    puts "Parsing source file: $file"
    read_verilog rtl/$file
}

# 3. Design Elaborate & Check
puts "Elaborating design hierarchy..."
hierarchy -top $top_level
procs

# 4. Synthesize and optimize for ice40
puts "Synthesizing design for ice40..."
synth_ice40 -json build/${top_level}_netlist.json

# 5. Print synthesis statistics
puts "========== SYNTHESIS STATISTICS =========="
stat
puts "========== END OF STATISTICS =========="

# 6. Save netlist files
puts "Writing netlist files..."
write_verilog "build/${top_level}_netlist.v"
write_verilog -noattr "build/${top_level}_netlist_noattr.v"

puts "Synthesis complete! Netlist: build/${top_level}_netlist.json"