`timescale 1ns / 1ps
// ============================================================================
//  Modulo: lcd_controller (Controlador y Formateador de Texto para LCD 1602)
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA · ITLA
// ============================================================================

module lcd_controller #(
    parameter CLK_FREQ = 50_000_000,
    parameter I2C_FREQ = 100_000,
    parameter I2C_ADDR = 7'h27
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       is_on,
    input  wire       mode_up,
    input  wire       is_done,
    input  wire [1:0] dot_step,
    input  wire [3:0] count,
    input  wire       sda_i,
    output wire       sda_oe,
    output wire       scl_oe
);

endmodule
