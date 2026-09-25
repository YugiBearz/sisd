`timescale 1ns / 1ps
// ============================================================================
//  Modulo: i2c_master (Capa Fisica del Maestro I2C)
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA · ITLA
// ============================================================================

module i2c_master #(
    parameter CLK_FREQ = 50_000_000,
    parameter I2C_FREQ = 100_000
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       i_start,
    input  wire       i_stop,
    input  wire       i_write,
    input  wire [7:0] i_data,
    output reg        o_ack,
    output reg        o_busy,
    output reg        o_done,
    input  wire       sda_i,
    output reg        sda_oe,
    output reg        scl_oe
);

    // Control Open-Drain:
    // sda_oe = 1 -> pone SDA en bajo (GND)
    // sda_oe = 0 -> libera SDA (pull-up externo a nivel logico alto)
    // scl_oe = 1 -> pone SCL en bajo (GND)
    // scl_oe = 0 -> libera SCL (pull-up externo a nivel logico alto)

    // Calculo del cuarto de periodo de reloj I2C para dividir cada ciclo en 4 fases
    localparam QP = CLK_FREQ / (4 * I2C_FREQ) - 1;

    // Codificacion de estados de la FSM
    localparam S_IDLE      = 3'd0;
    localparam S_START     = 3'd1;
    localparam S_WRITE_BIT = 3'd2;
    localparam S_READ_ACK  = 3'd3;
    localparam S_STOP      = 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_cnt;
    reg [1:0]  phase;
    reg [2:0]  bit_cnt;
    reg [7:0]  data_reg;

    wire phase_tick = (clk_cnt == QP[15:0]);

        always @(posedge clk) begin
        if (rst) begin
            state    <= S_IDLE;
            clk_cnt  <= 16'd0;
            phase    <= 2'd0;
            bit_cnt  <= 3'd0;
            data_reg <= 8'd0;
            sda_oe   <= 1'b0;
            scl_oe   <= 1'b0;
            o_ack    <= 1'b0;
            o_busy   <= 1'b0;
            o_done   <= 1'b0;
        end else begin
            o_done <= 1'b0;

            case (state)
                // Reposo: espera comando de START, transmision de byte o STOP
                S_IDLE: begin
                    o_busy <= 1'b0;
                    if (i_start) begin
                        state   <= S_START;
                        o_busy  <= 1'b1;
                        clk_cnt <= 16'd0;
                        phase   <= 2'd0;
                    end else if (i_write) begin
                        state    <= S_WRITE_BIT;
                        o_busy   <= 1'b1;
                        data_reg <= i_data;
                        bit_cnt  <= 3'd0;
                        clk_cnt  <= 16'd0;
                        phase    <= 2'd0;
                    end else if (i_stop) begin
                        state   <= S_STOP;
                        o_busy  <= 1'b1;
                        clk_cnt <= 16'd0;
                        phase   <= 2'd0;
                    end
                end

                // Generacion de condicion START: SDA cae mientras SCL permanece alto
                S_START: begin
                    if (phase_tick) begin
                        clk_cnt <= 16'd0;
                        phase   <= phase + 1'b1;
                        case (phase)
                            2'd0: begin sda_oe <= 1'b0; scl_oe <= 1'b0; end
                            2'd1: begin sda_oe <= 1'b1; end
                            2'd2: begin scl_oe <= 1'b1; end
                            2'd3: begin
                                state  <= S_IDLE;
                                o_done <= 1'b1;
                            end
                        endcase
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                // Escritura de byte: transmision serial de 8 bits (MSB primero)
                S_WRITE_BIT: begin
                    if (phase_tick) begin
                        clk_cnt <= 16'd0;
                        phase   <= phase + 1'b1;
                        case (phase)
                            2'd0: begin sda_oe <= ~data_reg[7]; scl_oe <= 1'b1; end
                            2'd1: begin scl_oe <= 1'b0; end
                            2'd2: begin end
                            2'd3: begin
                                scl_oe   <= 1'b1;
                                data_reg <= {data_reg[6:0], 1'b0};
                                if (bit_cnt == 3'd7) begin
                                    state   <= S_READ_ACK;
                                    bit_cnt <= 3'd0;
                                    phase   <= 2'd0;
                                end else begin
                                    bit_cnt <= bit_cnt + 1'b1;
                                end
                            end
                        endcase
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                // Lectura de bit ACK: el esclavo responde llevando SDA a bajo
                S_READ_ACK: begin
                    if (phase_tick) begin
                        clk_cnt <= 16'd0;
                        phase   <= phase + 1'b1;
                        case (phase)
                            2'd0: begin sda_oe <= 1'b0; scl_oe <= 1'b1; end
                            2'd1: begin scl_oe <= 1'b0; end
                            2'd2: begin o_ack <= sda_i; end
                            2'd3: begin
                                scl_oe <= 1'b1;
                                state  <= S_IDLE;
                                o_done <= 1'b1;
                            end
                        endcase
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                // Generacion de condicion STOP: SDA sube mientras SCL permanece alto
                S_STOP: begin
                    if (phase_tick) begin
                        clk_cnt <= 16'd0;
                        phase   <= phase + 1'b1;
                        case (phase)
                            2'd0: begin sda_oe <= 1'b1; scl_oe <= 1'b1; end
                            2'd1: begin scl_oe <= 1'b0; end
                            2'd2: begin sda_oe <= 1'b0; end
                            2'd3: begin
                                state  <= S_IDLE;
                                o_done <= 1'b1;
                            end
                        endcase
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
