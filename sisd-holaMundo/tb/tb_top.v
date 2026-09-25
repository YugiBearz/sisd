`timescale 1ns / 1ps
//
// ============================================================================
//  Testbench del hola mundo — 2025-0469
// ============================================================================
//
//  Comprueba la tabla de verdad completa del modulo: dos entradas posibles
//  por cada combinacion de polaridad. Son cinco casos y salen en el formato
//  que cuenta el CI:
//
//      [L1] caso 3: PASS
//
//  Este ejemplo no es un Code Challenge, asi que solo cubre el nivel L1. En
//  resultados.json veras L2 y L3 en cero: es correcto, no hay nada que medir.
//
module tb_top;

    reg  btn;

    // Placa por defecto: boton activo en bajo, LED activo en alto.
    wire led_normal;
    top #(.BUTTON_ACTIVE_LOW(1'b1), .LED_ACTIVE_LOW(1'b0))
        dut_normal (.btn_raw(btn), .led(led_normal));

    // Boton activo en alto: la polaridad de entrada se invierte.
    wire led_btn_alto;
    top #(.BUTTON_ACTIVE_LOW(1'b0), .LED_ACTIVE_LOW(1'b0))
        dut_btn_alto (.btn_raw(btn), .led(led_btn_alto));

    // LED activo en bajo: la polaridad de salida se invierte.
    wire led_inv;
    top #(.BUTTON_ACTIVE_LOW(1'b1), .LED_ACTIVE_LOW(1'b1))
        dut_led_inv (.btn_raw(btn), .led(led_inv));

    integer fallos = 0;

    task comprobar(input integer caso, input condicion, input [8*64:1] texto);
        begin
            if (condicion)
                $display("[L1] caso %0d: PASS  %0s", caso, texto);
            else begin
                $display("[L1] caso %0d: FAIL  %0s", caso, texto);
                fallos = fallos + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        $display("== Hola mundo 2025-0469 — Tang Primer 25K ==");

        // El pulsador de la Dock tiene pull-up externo: en reposo lee 1.
        btn = 1'b1;  #10;
        comprobar(1, led_normal === 1'b0, "en reposo (btn_raw=1) el LED esta apagado");

        btn = 1'b0;  #10;
        comprobar(2, led_normal === 1'b1, "pulsado (btn_raw=0) el LED se enciende");

        btn = 1'b1;  #10;
        comprobar(3, led_normal === 1'b0, "al soltar vuelve a apagarse, no se engancha");

        btn = 1'b1;  #10;
        comprobar(4, led_btn_alto === 1'b1,
                  "BUTTON_ACTIVE_LOW=0 invierte la lectura del boton");

        btn = 1'b0;  #10;
        comprobar(5, led_inv === 1'b0,
                  "LED_ACTIVE_LOW=1 invierte la salida hacia el pin");

        $display("== fallos: %0d ==", fallos);
        if (fallos == 0)
            $display("== el toolchain funciona de punta a punta ==");
        $finish;
    end

endmodule
