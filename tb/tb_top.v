`timescale 1ns / 1ps
// ============================================================================
//  Testbench de Verificación — Plantilla Base FPGA
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Sistemas Digitales con FPGA · ITLA
// ============================================================================

module tb_top;

    reg clk;
    reg rst_n;
    wire led;

    // Instancia del módulo bajo prueba (DUT)
    top dut (
        .clk   (clk),
        .rst_n (rst_n),
        .led   (led)
    );

    // Reloj de 50 MHz (período de 20 ns: 10 ns en alto, 10 ns en bajo)
    initial clk = 1'b0;
    always #10 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    initial begin
        // Volcado de formas de onda para GTKWave
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        $display("== Inicio de Simulacion: Plantilla Base 2025-0469 ==");

        // Caso 1: Reset activo
        rst_n = 1'b0;
        #40;
        if (dut.counter === 24'd0) begin
            $display("[L1] caso 1: PASS - Reset pone el contador en 0");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 1: FAIL - Contador no es 0 durante reset");
            fail_count = fail_count + 1;
        end

        // Caso 2: Liberar reset y verificar incremento
        rst_n = 1'b1;
        #60; // 3 ciclos de reloj
        if (dut.counter > 24'd0) begin
            $display("[L1] caso 2: PASS - Contador incrementa con el reloj");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 2: FAIL - Contador no incremento");
            fail_count = fail_count + 1;
        end

        // Resumen
        $display("== fallos: %0d ==", fail_count);
        if (fail_count == 0) begin
            $display("== Verificacion exitosa: todos los casos PASS ==");
        end else begin
            $display("== ERROR: Se detectaron fallos en la simulacion ==");
        end

        #100;
        $finish;
    end

endmodule

