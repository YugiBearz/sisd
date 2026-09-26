`timescale 1ns / 1ps
// ============================================================================
//  Testbench de Verificación Integral — Contador Reversible 0-9 con LCD 1602
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA · ITLA
// ============================================================================

module tb_top;

    reg clk;
    reg rst_btn;
    reg btn_on_off;
    reg btn_mode;
    reg btn_reset;

    wire io_sda;
    wire io_scl;

    // Resistencias Pull-up externas para simular el bus I2C
    pullup p1 (io_sda);
    pullup p2 (io_scl);

    // Instancia del sistema completo Top-Level
    top dut (
        .clk        (clk),
        .rst_btn    (rst_btn),
        .btn_on_off (btn_on_off),
        .btn_mode   (btn_mode),
        .btn_reset  (btn_reset),
        .io_sda     (io_sda),
        .io_scl     (io_scl)
    );

    // Reloj maestro de 50 MHz (periodo 20 ns)
    initial clk = 1'b0;
    always #10 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    // Tareas para simular pulsos de tiempo y botones
    task send_tick;
        begin
            @(negedge clk);
            force dut.tick_1hz = 1'b1;
            @(negedge clk);
            force dut.tick_1hz = 1'b0;
            release dut.tick_1hz;
            #20;
        end
    endtask
    task press_on_off;
        begin
            @(negedge clk);
            force dut.btn_on_off_pulse = 1'b1;
            @(negedge clk);
            force dut.btn_on_off_pulse = 1'b0;
            release dut.btn_on_off_pulse;
            #20;
        end
    endtask
    task press_mode;
        begin
            @(negedge clk);
            force dut.btn_mode_pulse = 1'b1;
            @(negedge clk);
            force dut.btn_mode_pulse = 1'b0;
            release dut.btn_mode_pulse;
            #20;
        end
    endtask
    task press_reset;
        begin
            @(negedge clk);
            force dut.btn_reset_pulse = 1'b1;
            @(negedge clk);
            force dut.btn_reset_pulse = 1'b0;
            release dut.btn_reset_pulse;
            #20;
        end
    endtask

    initial begin
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, tb_top);

        $display("============================================================");
        $display("  SIMULACION INTEGRAL: CONTADOR 0-9 CON LCD 1602 (ITLA)");
        $display("  Estudiante: Urik Valenzuela (2025-0469)");
        $display("============================================================");

        // Inicializacion de señales externas
        rst_btn    = 1'b0;
        btn_on_off = 1'b0;
        btn_mode   = 1'b0;
        btn_reset  = 1'b0;

        // Finalizar POR inmediatamente en el banco de pruebas
        #40;
        force dut.por_cnt = 20'hFFFFF;
        release dut.por_cnt;
        #40;

         // Caso 1: Estado inicial tras Reset y POR
        if (dut.count === 4'd0 && dut.mode_up === 1'b1 && dut.is_on === 1'b1 && dut.is_done === 1'b0) begin
            $display("[L1] caso 1: PASS - Estado inicial correcto (count=0, UP, ON, !done)");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 1: FAIL - Estado inicial incorrecto");
            fail_count = fail_count + 1;
        end


        #200;
        $finish;
    end

endmodule
