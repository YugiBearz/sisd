`timescale 1ns / 1ps
// ============================================================================
//  Testbench de Verificación Integral — Contador Reversible 0-9 con LCD 1602
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA
// ============================================================================

`ifdef VERILATOR
`include "../rtl/sync2ff.v"
`include "../rtl/debouncer.v"
`include "../rtl/tick_gen.v"
`include "../rtl/counter_fsm.v"
`include "../rtl/i2c_master.v"
`include "../rtl/lcd_pcf8574.v"
`include "../rtl/lcd_controller.v"
`include "../rtl/top.v"
`endif

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

                // Caso 2: Conteo Ascendente de 0 a 3
        send_tick(); // 1
        send_tick(); // 2
        send_tick(); // 3
        if (dut.count === 4'd3) begin
            $display("[L1] caso 2: PASS - Conteo ascendente avanza a 3 con pulsos tick_1hz");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 2: FAIL - Conteo no avanzo correctamente (count=%0d)", dut.count);
            fail_count = fail_count + 1;
        end

        // Caso 3: Conteo ascendente hasta 9
        repeat (6) send_tick(); // 4, 5, 6, 7, 8, 9
        if (dut.count === 4'd9) begin
            $display("[L1] caso 3: PASS - Conteo ascendente llega a 9 exitosamente");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 3: FAIL - Conteo no llego a 9 (count=%0d)", dut.count);
            fail_count = fail_count + 1;
        end

        // Caso 4: Deteccion de Fin de Conteo Ascendente (is_done)
        send_tick(); // Tick con count=9
        if (dut.is_done === 1'b1 && dut.count === 4'd9) begin
            $display("[L1] caso 4: PASS - Bandera is_done activada y conteo retenido en 9");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 4: FAIL - is_done no se activo tras llegar a 9");
            fail_count = fail_count + 1;
        end

                // Caso 5: Cambio de Modo a Descendente (debe preservar count=9 y limpiar is_done)
        press_mode();
        if (dut.mode_up === 1'b0 && dut.count === 4'd9 && dut.is_done === 1'b0) begin
            $display("[L1] caso 5: PASS - Modo cambio a Descendente preservando conteo en 9");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 5: FAIL - Error al alternar modo");
            fail_count = fail_count + 1;
        end

        // Caso 6: Conteo Descendente de 9 hacia 7
        send_tick(); // 8
        send_tick(); // 7
        if (dut.count === 4'd7) begin
            $display("[L1] caso 6: PASS - Conteo descendente decrementa correctamente a 7");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 6: FAIL - Conteo descendente incorrecto (count=%0d)", dut.count);
            fail_count = fail_count + 1;
        end

        // Caso 7: Conteo descendente continuo hasta 0
        repeat (7) send_tick(); // 6, 5, 4, 3, 2, 1, 0
        if (dut.count === 4'd0) begin
            $display("[L1] caso 7: PASS - Conteo descendente llega a 0 exitosamente");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 7: FAIL - Conteo no llego a 0 (count=%0d)", dut.count);
            fail_count = fail_count + 1;
        end

        // Caso 8: Deteccion de Fin de Conteo Descendente (is_done)
        send_tick(); // Tick con count=0
        if (dut.is_done === 1'b1 && dut.count === 4'd0) begin
            $display("[L1] caso 8: PASS - Bandera is_done activada en modo descendente reteniendo 0");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 8: FAIL - is_done no se activo tras llegar a 0");
            fail_count = fail_count + 1;
        end

                // Caso 9: Reset Condicional en modo descendente (debe reiniciar a 9)
        press_reset();
        if (dut.count === 4'd9 && dut.is_done === 1'b0) begin
            $display("[L1] caso 9: PASS - Reset condicional en modo descendente reinicio a 9");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 9: FAIL - Reset condicional no puso 9 en modo descendente");
            fail_count = fail_count + 1;
        end

        // Caso 10: Reset Condicional en modo ascendente (debe reiniciar a 0)
        press_mode(); // Cambiar a ascendente
        press_reset();
        if (dut.count === 4'd0 && dut.mode_up === 1'b1 && dut.is_done === 1'b0) begin
            $display("[L1] caso 10: PASS - Reset condicional en modo ascendente reinicio a 0");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 10: FAIL - Reset condicional no puso 0 en modo ascendente");
            fail_count = fail_count + 1;
        end

        // Caso 11: Control ON / OFF (Pausa/Reposo)
        press_on_off();
        if (dut.is_on === 1'b0) begin
            $display("[L1] caso 11: PASS - Boton ON/OFF pone el sistema en reposo (!is_on)");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 11: FAIL - Boton ON/OFF no apago el sistema");
            fail_count = fail_count + 1;
        end

        // Caso 12: Inmunidad a ticks mientras el sistema esta apagado
        send_tick();
        if (dut.count === 4'd0) begin
            $display("[L1] caso 12: PASS - Conteo pausado e inmune a ticks mientras esta apagado");
            pass_count = pass_count + 1;
        end else begin
            $display("[L1] caso 12: FAIL - Conteo avanzo estando apagado");
            fail_count = fail_count + 1;
        end

        press_on_off(); // Volver a encender

        // Resumen final de verificacion
        $display("============================================================");
        $display("  RESUMEN: %0d CASOS PASS | %0d CASOS FAIL", pass_count, fail_count);
        if (fail_count == 0) begin
            $display("  VERIFICACION EXITOSA: TODOS LOS CASOS PASS");
        end else begin
            $display("  ERROR: SE DETECTARON FALLOS EN LA SIMULACION");
        end
        $display("============================================================");

        #500;
        $finish;
    end

endmodule
