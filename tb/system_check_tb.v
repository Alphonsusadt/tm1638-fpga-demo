`timescale 1ns/1ps
module system_check_tb;
    reg clk = 0;
    wire cs, sclk;
    tri dio;
    reg [7:0] buttons = 0;
    integer bit_number = 0, byte_number = 0;
    integer packets = 0, frames = 0;
    integer key_index;
    reg [7:0] command = 0, received = 0;
    reg [7:0] response;
    top_tm1638_demo #(.CLOCK_HZ(20000)) dut (
        .clk(clk), .tm_cs(cs), .tm_clk(sclk), .tm_dio(dio)
    );
    always #5 clk = ~clk;
    always @(*) begin
        response = 0;
        case (byte_number)
            1: response = {3'b0, buttons[4], 3'b0, buttons[0]};
            2: response = {3'b0, buttons[5], 3'b0, buttons[1]};
            3: response = {3'b0, buttons[6], 3'b0, buttons[2]};
            4: response = {3'b0, buttons[7], 3'b0, buttons[3]};
        endcase
    end
    // Model the module's DIO output during the four key-read bytes.
    assign dio = (!cs && command == 8'h42 && byte_number > 0)
        ? response[bit_number] : 1'bz;
    always @(negedge cs) begin
        bit_number = 0;
        byte_number = 0;
        command = 0;
        received = 0;
    end
    always @(posedge sclk) begin
        if (!cs) begin
            received[bit_number] = dio;
            if (bit_number == 7) begin
                if (byte_number == 0) begin
                    command = received;
                    if (command !== 8'h42 && command !== 8'h40 &&
                        command !== 8'hc0 && command !== 8'h8f)
                        $fatal(1, "unexpected command %h", command);
                end else if (command == 8'hc0) begin
                    if (byte_number % 2 == 1) begin
                        if (received !== {1'b0, dut.frame[(byte_number - 1) / 2]})
                            $fatal(1, "digit transfer mismatch");
                    end else if (received !== {7'b0, dut.led_data[(byte_number - 2) / 2]})
                        $fatal(1, "LED transfer mismatch");
                end
                byte_number = byte_number + 1;
                bit_number = 0;
                received = 0;
            end else bit_number = bit_number + 1;
        end
    end
    always @(posedge cs) begin
        if (!dut.rst && byte_number > 0) begin
            if (bit_number != 0) $fatal(1, "partial byte at end of packet");
            case (command)
                8'h42: if (byte_number != 5) $fatal(1, "key-read length");
                8'hc0: begin
                    if (byte_number != 17) $fatal(1, "display packet length");
                    frames = frames + 1;
                end
                default: if (byte_number != 1) $fatal(1, "command length");
            endcase
            packets = packets + 1;
        end
    end
    task wait_scan;
        begin
            @(negedge clk);
            wait (dut.instruction_step == 0 && !dut.busy);
            @(negedge clk);
        end
    endtask
    initial begin
        repeat (5) @(negedge clk);
        for (key_index = 0; key_index < 8; key_index = key_index + 1) begin
            wait_scan;
            buttons = 8'b1 << key_index;
            wait (dut.keys === buttons);
            repeat (2) @(negedge clk);
            if (dut.mode !== ((key_index == 0) ? 2'b00 : (key_index == 1) ? 2'b01 : 2'b10))
                $fatal(1, "button mode mismatch at S%d", key_index + 1);
            wait_scan;
        end
        buttons = 0;
        wait (dut.keys === 0);
        wait_scan;
        if (dut.mode !== 2'b10) $fatal(1, "release lost selected right mode");
        buttons = 8'h02;
        wait (dut.keys === buttons);
        repeat (2) @(negedge clk);
        if (dut.mode !== 2'b01) $fatal(1, "S2 did not select left");
        wait_scan;
        // A new S3 press must override an already held S2.
        buttons = 8'h06;
        wait (dut.keys === buttons);
        repeat (2) @(negedge clk);
        if (dut.mode !== 2'b10) $fatal(1, "new S3 did not override held S2");
        wait_scan;
        buttons = 0;
        wait (dut.keys === 0);
        wait_scan;
        if (dut.mode !== 2'b10) $fatal(1, "release changed right mode");
        buttons = 8'h07;
        wait (dut.keys === buttons);
        repeat (2) @(negedge clk);
        if (dut.mode !== 2'b00) $fatal(1, "simultaneous presses must prioritize S1");
        wait_scan;
        if (frames < 8) $fatal(1, "too few display frames");
        $display("PASS: key mapping, latched modes/release, new press overrides held key, priority, DIO, %d frames", frames);
        $finish;
    end
    initial begin
        #10000000;
        $fatal(1, "system timeout");
    end
endmodule
