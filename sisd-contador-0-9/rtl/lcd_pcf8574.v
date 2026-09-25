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

endmodule