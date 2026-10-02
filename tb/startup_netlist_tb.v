`timescale 1ns/1ps
module startup_netlist_tb;
    reg clk = 0;
    reg [7:0] buttons = 0;
    reg [7:0] response;
    reg [1:0] expected_mode = 0;
    reg [7:0] previous_buttons = 0;
    wire [7:0] new_buttons = buttons & ~previous_buttons;
    wire cs, sclk;
    tri dio;
    reg [7:0] command = 0, received = 0;
    integer bit_number = 0, byte_number = 0;
    integer frames = 0;
    top_tm1638_demo dut (.clk(clk), .tm_cs(cs), .tm_clk(sclk), .tm_dio(dio));
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
    assign dio = (!cs && command == 8'h42 && byte_number > 0) ? response[bit_number] : 1'bz;
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
                        $fatal(1, "netlist command invalid: %h", command);
                end else if (command == 8'hc0) begin
                    if (byte_number % 2 == 1 && received !== 0)
                        $fatal(1, "netlist initial digit must be blank, got %h", received);
                    if (byte_number % 2 == 0 && received !==
                        ((expected_mode == 0 && byte_number == 2) ||
                         (expected_mode == 1 && byte_number == 4) ||
                         (expected_mode == 2 && byte_number == 6) ? 8'h01 : 8'h00))
                        $fatal(1, "netlist button mode LED mismatch, buttons=%h byte=%d", buttons, byte_number);
                end
                byte_number = byte_number + 1;
                bit_number = 0;
                received = 0;
            end else bit_number = bit_number + 1;
        end
    end
    always @(posedge cs) begin
        if (byte_number > 0) begin
            if (bit_number != 0) $fatal(1, "partial netlist byte");
            case (command)
                8'h42: begin
                    if (byte_number != 5) $fatal(1, "netlist key packet length");
                    if (new_buttons[0]) expected_mode = 0;
                    else if (new_buttons[1]) expected_mode = 1;
                    else if (new_buttons[2]) expected_mode = 2;
                    previous_buttons = buttons;
                end
                8'hc0: begin
                    if (byte_number != 17) $fatal(1, "netlist display packet length");
                    frames = frames + 1;
                end
                default: if (byte_number != 1) $fatal(1, "netlist control packet length");
            endcase
        end
    end
    initial begin
        wait (frames == 1); buttons = 8'h01;
        wait (frames == 2); buttons = 8'h00;
        wait (frames == 3); buttons = 8'h02;
        wait (frames == 4); buttons = 8'h00;
        wait (frames == 6); buttons = 8'h04;
        wait (frames == 7); buttons = 8'h00;
        wait (frames == 9); buttons = 8'h07;
        wait (frames == 10); buttons = 8'h00;
        wait (frames == 11);
        $display("PASS: synthesized FPGA startup, latched S1/S2/S3 and LEDs after release, priority, eleven frames");
        $finish;
    end
    initial begin
        #2000000;
        $fatal(1, "netlist startup timeout");
    end
endmodule
