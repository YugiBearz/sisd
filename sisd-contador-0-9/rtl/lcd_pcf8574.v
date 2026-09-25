`timescale 1ns / 1ps
// ============================================================================
//  Modulo: lcd_pcf8574 (Controlador de LCD 1602 via Expansor I2C PCF8574)
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA · ITLA
// ============================================================================

module lcd_pcf8574 #(
    parameter CLK_FREQ = 50_000_000,
    parameter I2C_FREQ = 100_000,
    parameter I2C_ADDR = 7'h27
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] i_data,
    input  wire       i_rs,
    input  wire       i_nibble_mode,
    input  wire       i_start,
    output reg        o_busy,
    output reg        o_done,
    input  wire       sda_i,
    output wire       sda_oe,
    output wire       scl_oe
);

    // Retardo para el pulso de Enable del HD44780
    localparam EN_DELAY = 50;

    // Micropasos de transmision por I2C
    localparam STEP_START1    = 4'd0;
    localparam STEP_ADDR1     = 4'd1;
    localparam STEP_DATA_HI   = 4'd2;
    localparam STEP_STOP1     = 4'd3;
    localparam STEP_EN_WAIT   = 4'd4;
    localparam STEP_START2    = 4'd5;
    localparam STEP_ADDR2     = 4'd6;
    localparam STEP_DATA_LO   = 4'd7;
    localparam STEP_STOP2     = 4'd8;
    localparam STEP_NEXT      = 4'd9;
    localparam STEP_DONE      = 4'd10;

    // Estados de la FSM
    localparam S_IDLE  = 2'd0;
    localparam S_EXEC  = 2'd1;
    localparam S_WAIT  = 2'd2;
    localparam S_DELAY = 2'd3;

    reg [1:0]  state;
    reg [3:0]  step;
    reg [3:0]  lo_nib;
    reg        rs_lat;
    reg        nib_mode;
    reg        nib_phase;
    reg [3:0]  cur_nib;
    reg [7:0]  delay_cnt;

    reg        i2c_start;
    reg        i2c_stop;
    reg        i2c_write;
    reg [7:0]  i2c_wdata;
    wire       i2c_done;

    // Instancia de la capa fisica I2C
    i2c_master #(
        .CLK_FREQ(CLK_FREQ),
        .I2C_FREQ(I2C_FREQ)
    ) u_i2c (
        .clk    (clk),
        .rst    (rst),
        .i_start(i2c_start),
        .i_stop (i2c_stop),
        .i_write(i2c_write),
        .i_data (i2c_wdata),
        /* verilator lint_off PINCONNECTEMPTY */
        .o_ack  (),
        .o_busy (),
        /* verilator lint_on PINCONNECTEMPTY */
        .o_done (i2c_done),
        .sda_i  (sda_i),
        .sda_oe (sda_oe),
        .scl_oe (scl_oe)
    );

    // Mapeo del PCF8574: [7:4]=Dato, [3]=Backlight, [2]=EN, [1]=RW, [0]=RS
    wire [7:0] pcf_byte_en_hi = {cur_nib, 1'b1, 1'b1, 1'b0, rs_lat};
    wire [7:0] pcf_byte_en_lo = {cur_nib, 1'b1, 1'b0, 1'b0, rs_lat};
    wire [7:0] addr_byte      = {I2C_ADDR, 1'b0};

    always @(posedge clk) begin
        if (rst) begin
            state     <= S_IDLE;
            step      <= 4'd0;
            o_busy    <= 1'b0;
            o_done    <= 1'b0;
            i2c_start <= 1'b0;
            i2c_stop  <= 1'b0;
            i2c_write <= 1'b0;
            i2c_wdata <= 8'd0;
            lo_nib    <= 4'd0;
            rs_lat    <= 1'b0;
            nib_mode  <= 1'b0;
            nib_phase <= 1'b0;
            cur_nib   <= 4'd0;
            delay_cnt <= 8'd0;
        end else begin
            o_done    <= 1'b0;
            i2c_start <= 1'b0;
            i2c_stop  <= 1'b0;
            i2c_write <= 1'b0;
        end
    end

endmodule
