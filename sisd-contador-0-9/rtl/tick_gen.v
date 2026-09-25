`timescale 1ns / 1ps
// ============================================================================
//  Módulo: tick_gen (Generador de Ticks - Clock Enable)
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA · ITLA
// ============================================================================

module tick_gen #(
    parameter CLK_HZ = 50_000_000
)(
    input wire clk,
    input wire rst_n,
    output reg tick_1hz
);

    localparam CNT_1HZ_MAX = CLK_HZ - 1;

    reg [25:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt      <= 26'd0;
            tick_1hz <= 1'b0;
        end else begin
            if (cnt == CNT_1HZ_MAX) begin
                cnt      <= 26'd0;
                tick_1hz <= 1'b1;
            end else begin
                cnt <= cnt + 1'b1;
                tick_1hz <= 1'b0;
            end
        end
    end

endmodule
