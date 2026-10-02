`timescale 1ns/1ps
module production_clock_tb;
    reg clk = 0;
    wire cs, sclk;
    tri dio;
    integer cycle_number;
    top_tm1638_demo dut (.clk(clk), .tm_cs(cs), .tm_clk(sclk), .tm_dio(dio));
    always #5 clk = ~clk;
    initial begin
        // Exercise the unmodified production divider, not a smaller parameter.
        force dut.instruction_step = 0;
        force dut.scan_div = 0;
        @(negedge clk);
        if (dut.scroll_pos !== 0 || dut.anim_counter !== 0)
            $fatal(1, "power-on reset failed");
        for (cycle_number = 1; cycle_number <= 12000000; cycle_number = cycle_number + 1) begin
            @(negedge clk);
            if (cycle_number < 12000000 && dut.scroll_pos !== 0)
                $fatal(1, "production divider moved early at %d", cycle_number);
        end
        if (dut.scroll_pos !== 1 || dut.anim_counter !== 0)
            $fatal(1, "production divider did not move at exactly 12000000 cycles");
        $display("PASS: power-on reset and production 12 MHz divider, exactly 12000000 cycles per step");
        $finish;
    end
endmodule
