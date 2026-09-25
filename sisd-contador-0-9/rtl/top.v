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

    // Sincronizacion de botones externos (2 flip-flops contra metaestabilidad)
    wire btn_on_off_sync;
    wire btn_mode_sync;
    wire btn_reset_sync;

    sync2ff u_sync_on_off (
        .clk     (clk),
        .rst_n   (sys_rst_n),
        .async_in(btn_on_off),
        .sync_out(btn_on_off_sync)
    );

    sync2ff u_sync_mode (
        .clk     (clk),
        .rst_n   (sys_rst_n),
        .async_in(btn_mode),
        .sync_out(btn_mode_sync)
    );

    sync2ff u_sync_reset (
        .clk     (clk),
        .rst_n   (sys_rst_n),
        .async_in(btn_reset),
        .sync_out(btn_reset_sync)
    );

    // Filtros antirrebote y deteccion de flancos (20 ms por pulsador)
    wire btn_on_off_pulse;
    wire btn_mode_pulse;
    wire btn_reset_pulse;

    /* verilator lint_off PINCONNECTEMPTY */
    debouncer #(
        .CLK_HZ     (50_000_000),
        .DEBOUNCE_MS(20)
    ) u_deb_on_off (
        .clk      (clk),
        .rst_n    (sys_rst_n),
        .btn_in   (btn_on_off_sync),
        .btn_clean(),
        .pulse    (btn_on_off_pulse)
    );

    debouncer #(
        .CLK_HZ     (50_000_000),
        .DEBOUNCE_MS(20)
    ) u_deb_mode (
        .clk      (clk),
        .rst_n    (sys_rst_n),
        .btn_in   (btn_mode_sync),
        .btn_clean(),
        .pulse    (btn_mode_pulse)
    );

    debouncer #(
        .CLK_HZ     (50_000_000),
        .DEBOUNCE_MS(20)
    ) u_deb_reset (
        .clk      (clk),
        .rst_n    (sys_rst_n),
        .btn_in   (btn_reset_sync),
        .btn_clean(),
        .pulse    (btn_reset_pulse)
    );
    /* verilator lint_on PINCONNECTEMPTY */

    // Generador de reloj de 1 Hz (pulso de 1 ciclo)
    wire tick_1hz;

    tick_gen #(
        .CLK_HZ(50_000_000)
    ) u_tick (
        .clk     (clk),
        .rst_n   (sys_rst_n),
        .tick_1hz(tick_1hz)
    );

    // FSM del contador reversible 0-9
    wire [3:0] count;
    wire       mode_up;
    wire       is_on;
    wire       is_done;
    wire [1:0] dot_step;

    counter_fsm u_counter (
        .clk              (clk),
        .rst_n            (sys_rst_n),
        .tick_1hz         (tick_1hz),
        .btn_on_off_pulse (btn_on_off_pulse),
        .btn_mode_pulse   (btn_mode_pulse),
        .btn_reset_pulse  (btn_reset_pulse),
        .count            (count),
        .mode_up          (mode_up),
        .is_on            (is_on),
        .is_done          (is_done),
        .dot_step         (dot_step)
    );

    // Controlador y formateador para LCD 1602 (I2C PCF8574)
    lcd_controller #(
        .CLK_FREQ(50_000_000),
        .I2C_FREQ(100_000),
        .I2C_ADDR(7'h27)
    ) u_lcd_ctrl (
        .clk     (clk),
        .rst     (sys_rst),
        .is_on   (is_on),
        .mode_up (mode_up),
        .is_done (is_done),
        .dot_step(dot_step),
        .count   (count),
        .sda_i   (sda_in),
        .sda_oe  (sda_oe),
        .scl_oe  (scl_oe)
    );

endmodule
