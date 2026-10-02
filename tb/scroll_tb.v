`timescale 1ns/1ps
module scroll_tb;
    reg clk = 0;
    wire cs, sclk;
    tri dio;
    integer expected_pos = 0;
    integer cycles;
    integer i;
    reg [6:0] saved_frame [0:7];
    top_tm1638_demo #(.CLOCK_HZ(16)) dut (
        .clk(clk), .tm_cs(cs), .tm_clk(sclk), .tm_dio(dio)
    );
    always #5 clk = ~clk;

    task check_buffer;
        integer j;
        begin
            if (dut.scroll_pos !== expected_pos)
                $fatal(1, "position: got %d expected %d", dut.scroll_pos, expected_pos);
            for (j = 0; j < 44; j = j + 1)
                if (dut.scroll_buffer[j] !== dut.text_char(j - 26 + expected_pos))
                    $fatal(1, "buffer mismatch at %d, position %d", j, expected_pos);
        end
    endtask

    task step;
        input integer next_pos;
        begin
            for (cycles = 0; cycles < 15; cycles = cycles + 1) begin
                @(posedge clk); #1;
                check_buffer;
            end
            @(posedge clk); #1;
            expected_pos = next_pos;
            check_buffer;
        end
    endtask

    initial begin
        // Keep protocol idle while testing animation independently.
        force dut.instruction_step = 0;
        force dut.keys = 8'h00;
        @(posedge clk); #1;
        check_buffer;
        // Idle mode must also use the full one-second divider.
        for (i = 1; i <= 26; i = i + 1) step(i);
        for (i = 25; i >= 0; i = i - 1) step(i);
        step(1);
        // 01: continuous left, including restart after fully leaving screen.
        force dut.keys = 8'h02;
        step(2);
        force dut.keys = 8'h00;
        for (i = 3; i <= 26; i = i + 1) step(i);
        step(0);
        // 10: continuous right, including restart.
        force dut.keys = 8'h04;
        step(26);
        force dut.keys = 8'h00;
        for (i = 25; i >= 0; i = i - 1) step(i);
        step(26);
        // 00 ping-pongs at both boundaries.
        force dut.keys = 8'h01;
        step(25);
        force dut.keys = 8'h00;
        for (i = 24; i >= 0; i = i - 1) step(i);
        step(1);

        force dut.keys = 8'h07;
        step(2);
        force dut.keys = 8'h00;
        step(3);

        // Capture one frame and ensure later animation cannot tear it.
        force dut.instruction_step = 15;
        force dut.scan_div = 1;
        @(posedge clk); #1;
        for (i = 0; i < 8; i = i + 1) begin
            saved_frame[i] = dut.scroll_buffer[18 + i];
            if (dut.frame[i] !== saved_frame[i]) $fatal(1, "snapshot mismatch");
        end
        force dut.instruction_step = 0;
        repeat (32) @(posedge clk);
        #1;
        for (i = 0; i < 8; i = i + 1)
            if (dut.frame[i] !== saved_frame[i]) $fatal(1, "frame changed during transfer");
        $display("PASS: S1/S2/S3 latched modes after release, priority, timing, 44 entries, wraps, frame snapshot");
        $finish;
    end
endmodule
