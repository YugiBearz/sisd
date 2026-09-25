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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count    <= 4'd0;
            mode_up  <= 1'b1;
            is_on    <= 1'b1;
            is_done  <= 1'b0;
            dot_step <= 2'd0;
        end else begin
            if (btn_on_off_pulse) begin
                is_on <= ~is_on;
            end
            if (btn_mode_pulse) begin
                mode_up <= ~mode_up;
                is_done <= 1'b0;
            end
            if (btn_reset_pulse) begin
                is_done  <= 1'b0;
                dot_step <= 2'd0;
                if (mode_up) begin
                    count <= 4'd0;
                end else begin
                    count <= 4'd9;
                end
            end else if (is_on && !is_done && tick_1hz) begin
                if (dot_step == 2'd2) begin
                    dot_step <= 2'd0;
                end else begin
                    dot_step <= dot_step + 1'b1;
                end
                if (mode_up) begin
                    if (count < 4'd9) begin
                        count <= count + 1'b1;
                    end else begin
                        is_done <= 1'b1;
                    end
                end else begin
                    if (count > 4'd0) begin
                        count <= count - 1'b1;
                    end else begin
                        is_done <= 1'b1;
                    end
                end
            end
        end
    end
endmodule
