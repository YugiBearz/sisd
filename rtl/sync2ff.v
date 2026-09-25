`timescale 1ns / 1ps
// ==========================================================================
// Módulo: sync2ff (Sincronizador de 2 Flip-Flops)
// Autor: Urik Valenzuela · Matricula: 2025-0469 · 20250469@itla.edu.do
// Asignatura: Sistemas Digitales
// Cumplimiento: Regla RAE3.2
// ==========================================================================

module sync2ff (
    input wire clk,
    input wire rst_n,
    input wire async_in,
    output wire sync_out
);

reg ff1;
reg ff2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ff1 <= 1'b0;
        ff2 <= 1'b0;
    end else begin
        ff1 <= async_in;
        ff2 <= ff1;
    end
end

assign sync_out = ff2;

endmodule
