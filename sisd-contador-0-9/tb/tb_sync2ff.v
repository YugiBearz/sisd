`timescale 1ns / 1ps

module tb_sync2ff;

    reg clk;
    reg rst_n;
    reg async_in;
    wire sync_out;

    sync2ff uut (
        .clk        (clk),
        .rst_n      (rst_n),
        .async_in   (async_in),
        .sync_out   (sync_out)
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_sync2ff);

        clk         = 0;
        rst_n       = 0;
        async_in    = 0;

        #30;
        rst_n = 1;

        #15;
        async_in = 1;

        #60;
        async_in = 0;

        #40;
        $display("Testbench finalizado con exito.");
        $finish;
    end

endmodule
