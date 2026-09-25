`timescale 1ns / 1ps
// ============================================================================
//  Modulo: counter_fsm (Control de Estados y Contador 0-9 Reversible)
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA
// ============================================================================

module counter_fsm (
    input wire clk,
    input wire rst_n,
    input wire tick_1hz,
    input wire btn_on_off_pulse,
    input wire btn_mode_pulse,
    input wire btn_reset_pulse,
    output reg [3:0] count,
    output reg mode_up,
    output reg is_on,
    output reg is_done,
    output reg [1:0] dot_step
);