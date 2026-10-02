`timescale 1ns/1ps
module driver_check_tb;
    reg clk = 0, rst = 1, rw = 1, latch = 0;
    reg [7:0] tx = 0;
    wire [7:0] data;
    wire busy, sclk, dout;
    reg din = 0;
    reg [7:0] serial_tx = 0;
    reg [7:0] serial_rx = 0;
    integer bit_index = 0;
    integer rising_edges = 0;
    assign data = rw ? tx : 8'bz;
    tm1638 dut (.clk(clk), .rst(rst), .data_latch(latch), .data(data),
        .rw(rw), .busy(busy), .sclk(sclk), .dio_in(din), .dio_out(dout));
    always #5 clk = ~clk;
    always @(negedge sclk) begin
        din = serial_rx[bit_index];
    end
    always @(posedge sclk) begin
        if (!rst && busy) begin
            serial_tx[bit_index] = dout;
            bit_index = bit_index + 1;
            rising_edges = rising_edges + 1;
        end
    end
    task transfer;
        input write_mode;
        input [7:0] value;
        begin
            @(negedge clk);
            rw = write_mode;
            tx = value;
            serial_rx = value;
            bit_index = 0;
            rising_edges = 0;
            serial_tx = 0;
            latch = 1;
            @(negedge clk); latch = 0;
            wait(busy);
            wait(!busy); #1;
            if (rising_edges != 8) $fatal(1, "transfer has %d clock edges", rising_edges);
            if (write_mode && serial_tx !== value)
                $fatal(1, "serial TX got %h expected %h", serial_tx, value);
            if (!write_mode && data !== value)
                $fatal(1, "serial RX got %h expected %h", data, value);
        end
    endtask
    initial begin
        repeat (3) @(negedge clk);
        rst = 0;
        transfer(1, 8'h40);
        transfer(1, 8'haa);
        transfer(1, 8'h55);
        transfer(0, 8'haa);
        transfer(0, 8'h55);
        transfer(0, 8'h00);
        transfer(0, 8'hff);
        $display("PASS: serial TX/RX, LSB-first order, eight clock edges per byte");
        $finish;
    end
    initial begin
        #1000000;
        $fatal(1, "driver timeout");
    end
endmodule
