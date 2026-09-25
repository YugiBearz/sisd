`timescale 1ns / 1ps
// ============================================================================
//  Modulo: top (Integracion Top-Level - Contador Reversible 0-9 con LCD 1602)
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA · ITLA
// ============================================================================

module top (
    input  wire clk,            // 50 MHz reloj principal (pin E2)
    input  wire rst_btn,        // Boton S1 onboard (pin H11, pull-down)
    input  wire btn_on_off,     // Boton 1 externo: ON / OFF
    input  wire btn_mode,       // Boton 2 externo: Modo Ascendente / Descendente
    input  wire btn_reset,      // Boton 3 externo: Reset condicional
    inout  wire io_sda,         // I2C SDA (pin K1)
    inout  wire io_scl          // I2C SCL (pin K2)
);

    // Power-on reset: ~21 ms a 50 MHz para estabilizacion de la pantalla LCD
    reg [19:0] por_cnt;
    initial por_cnt = 20'd0;
    wire       por_rst = (por_cnt != 20'hFFFFF);
    wire       sys_rst = por_rst | rst_btn;    // Activo en alto
    wire       sys_rst_n = ~sys_rst;           // Activo en bajo

    always @(posedge clk) begin
        if (por_cnt != 20'hFFFFF)
            por_cnt <= por_cnt + 1'b1;
    end

    // Control Open-Drain para el bus I2C (oe=1 -> GND, oe=0 -> Alta impedancia con pull-up)
    wire sda_oe;
    wire scl_oe;
    wire sda_in = io_sda;

    assign io_sda = sda_oe ? 1'b0 : 1'bz;
    assign io_scl = scl_oe ? 1'b0 : 1'bz;

endmodule