`timescale 1ns / 1ps
// ==========================================================================
// Módulo: debouncer (Filtro Antirrebote + Detector de Flanco)
// Autor: Urik Valenzuela · Matricula: 2025-0469 · 20250469@itla.edu.do
// Asignatura: Sistemas Digitales
// ==========================================================================

module debounder #(
    parameter CLK_HZ        = 50_000_000,
    parameter DEBOUNCE_MS   = 20   
)(
    input wire clk,
    input wire rst_n,
    input wire btn_in,
    output wire btn_clean, 
    output wire pulse
);

    localparam CNT_MAX = (CLK_HZ / 1000) * DEBOUNCE_MS - 1;
    localparam CNT_W = 20;

    reg [CNT_W-1:0] cnt;
    reg             stable;
    reg             stable_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt      <= 20'd0;
            stable   <= 1'b0;
            stable_d <= 1'b0;
        end else begin

        stable_d <= stable;

        if (btn_in != stable) begin
            if (cnt == CNT_MAX[CNT_W-1:0]) begin
                stable <= btn_in;
                cnt    <= 20'd0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end else begin
            cnt <= 20'd0;
        end
    end
end

assign btn_clean = stable;
assign pulse     = stable & ~stable_d;

endmodule
