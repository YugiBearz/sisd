`timescale 1ns / 1ps
// ============================================================================
//  Plantilla Base FPGA — Tang Primer 25K (GW5A-25)
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Sistemas Digitales con FPGA · ITLA
// ============================================================================

module top (
    input  wire clk,      // Reloj principal (50 MHz, pin E2)
    input  wire rst_n,    // Reset activo-bajo (o botón S1)
    output wire led       // Salida de prueba
);

    // Contador de prueba de 24 bits
    reg [23:0] counter;

    initial begin
        counter = 24'd0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 24'd0;
        end else begin
            counter <= counter + 1'b1;
        end
    end

    // El bit 23 conmuta aproximadamente cada 0.168 segundos (~3 Hz)
    assign led = counter[23];

endmodule

