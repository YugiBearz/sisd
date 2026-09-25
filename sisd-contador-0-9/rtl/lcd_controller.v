`timescale 1ns / 1ps
// ============================================================================
//  Modulo: lcd_controller (Controlador y Formateador de Texto para LCD 1602)
//  Autor: Urik Valenzuela · Matrícula: 2025-0469 · 20250469@itla.edu.do
//  Asignatura: Sistemas Digitales con FPGA · ITLA
// ============================================================================

module lcd_controller #(
    parameter CLK_FREQ = 50_000_000,
    parameter I2C_FREQ = 100_000,
    parameter I2C_ADDR = 7'h27
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       is_on,
    input  wire       mode_up,
    input  wire       is_done,
    input  wire [1:0] dot_step,
    input  wire [3:0] count,
    input  wire       sda_i,
    output wire       sda_oe,
    output wire       scl_oe
);

    localparam LCD_COLS    = 16;
    localparam DELAY_40MS  = CLK_FREQ / 25;
    localparam DELAY_5MS   = CLK_FREQ / 200;
    localparam DELAY_2MS   = CLK_FREQ / 500;
    localparam DELAY_200US = CLK_FREQ / 5000;
    localparam DELAY_50US  = CLK_FREQ / 20000;

    localparam INIT_STEPS = 9;

    // Estados principales del controlador
    localparam S_INIT_DELAY = 3'd0;
    localparam S_INIT_CMD   = 3'd1;
    localparam S_INIT_WAIT  = 3'd2;
    localparam S_LINE_ADDR  = 3'd3;
    localparam S_CMD_WAIT   = 3'd4;
    localparam S_LINE_DATA  = 3'd5;

    reg [2:0]  state;
    reg [3:0]  init_step;
    reg [20:0] delay_cnt;

        reg [4:0]  char_idx;
    reg        line_sel;

    reg        lcd_start;
    reg [7:0]  lcd_data;
    reg        lcd_rs;
    reg        lcd_nib;
    wire       lcd_busy;
    wire       lcd_done;

    // Instancia del controlador de bajo nivel PCF8574
    lcd_pcf8574 #(
        .CLK_FREQ(CLK_FREQ),
        .I2C_FREQ(I2C_FREQ),
        .I2C_ADDR(I2C_ADDR)
    ) u_lcd (
        .clk          (clk),
        .rst          (rst),
        .i_data       (lcd_data),
        .i_rs         (lcd_rs),
        .i_nibble_mode(lcd_nib),
        .i_start      (lcd_start),
        .o_busy       (lcd_busy),
        .o_done       (lcd_done),
        .sda_i        (sda_i),
        .sda_oe       (sda_oe),
        .scl_oe       (scl_oe)
    );

    // Secuencia de inicializacion estandar HD44780 en modo 4 bits
    reg [7:0]  init_cmd_data;
    reg        init_cmd_nib;
    reg [20:0] init_cmd_delay;
    always @(*) begin
        case (init_step)
            4'd0: begin init_cmd_data = 8'h30; init_cmd_nib = 1'b1; init_cmd_delay = DELAY_5MS[20:0];   end
            4'd1: begin init_cmd_data = 8'h30; init_cmd_nib = 1'b1; init_cmd_delay = DELAY_200US[20:0]; end
            4'd2: begin init_cmd_data = 8'h30; init_cmd_nib = 1'b1; init_cmd_delay = DELAY_200US[20:0]; end
            4'd3: begin init_cmd_data = 8'h20; init_cmd_nib = 1'b1; init_cmd_delay = DELAY_200US[20:0]; end
            4'd4: begin init_cmd_data = 8'h28; init_cmd_nib = 1'b0; init_cmd_delay = DELAY_50US[20:0];  end
            4'd5: begin init_cmd_data = 8'h0C; init_cmd_nib = 1'b0; init_cmd_delay = DELAY_50US[20:0];  end
            4'd6: begin init_cmd_data = 8'h06; init_cmd_nib = 1'b0; init_cmd_delay = DELAY_50US[20:0];  end
            4'd7: begin init_cmd_data = 8'h01; init_cmd_nib = 1'b0; init_cmd_delay = DELAY_2MS[20:0];   end
            4'd8: begin init_cmd_data = 8'h02; init_cmd_nib = 1'b0; init_cmd_delay = DELAY_2MS[20:0];   end
            default: begin init_cmd_data = 8'h00; init_cmd_nib = 1'b0; init_cmd_delay = DELAY_50US[20:0]; end
        endcase
    end

    // Generador combinacional de caracteres para linea 1 y linea 2
    reg [7:0] char_data;
    always @(*) begin
        if (!line_sel) begin
            // Linea 1: Estados del sistema
            if (!is_on) begin
                case (char_idx[3:0])
                    4'd0:  char_data = "[";
                    4'd1:  char_data = "S";
                    4'd2:  char_data = "Y";
                    4'd3:  char_data = "S";
                    4'd4:  char_data = "T";
                    4'd5:  char_data = "E";
                    4'd6:  char_data = "M";
                    4'd7:  char_data = ":";
                    4'd8:  char_data = " ";
                    4'd9:  char_data = "O";
                    4'd10: char_data = "F";
                    4'd11: char_data = "F";
                    4'd12: char_data = "]";
                    default: char_data = " ";
                endcase
            end else if (is_done) begin
                case (char_idx[3:0])
                    4'd0:  char_data = "C";
                    4'd1:  char_data = "o";
                    4'd2:  char_data = "u";
                    4'd3:  char_data = "n";
                    4'd4:  char_data = "t";
                    4'd5:  char_data = " ";
                    4'd6:  char_data = "C";
                    4'd7:  char_data = "o";
                    4'd8:  char_data = "m";
                    4'd9:  char_data = "p";
                    4'd10: char_data = "l";
                    4'd11: char_data = "e";
                    4'd12: char_data = "t";
                    4'd13: char_data = "e";
                    4'd14: char_data = "d";
                    4'd15: char_data = "!";
                    default: char_data = " ";
                endcase
            end else if (mode_up) begin
                case (char_idx[3:0])
                    4'd0:  char_data = "A";
                    4'd1:  char_data = "s";
                    4'd2:  char_data = "c";
                    4'd3:  char_data = "e";
                    4'd4:  char_data = "n";
                    4'd5:  char_data = "d";
                    4'd6:  char_data = "i";
                    4'd7:  char_data = "n";
                    4'd8:  char_data = "g";
                    4'd9:  char_data = ".";
                    4'd10: char_data = (dot_step >= 2'd1) ? "." : " ";
                    4'd11: char_data = (dot_step >= 2'd2) ? "." : " ";
                    default: char_data = " ";
                endcase
            end else begin
                case (char_idx[3:0])
                    4'd0:  char_data = "D";
                    4'd1:  char_data = "e";
                    4'd2:  char_data = "s";
                    4'd3:  char_data = "c";
                    4'd4:  char_data = "e";
                    4'd5:  char_data = "n";
                    4'd6:  char_data = "d";
                    4'd7:  char_data = "i";
                    4'd8:  char_data = "n";
                    4'd9:  char_data = "g";
                    4'd10: char_data = ".";
                    4'd11: char_data = (dot_step >= 2'd1) ? "." : " ";
                    4'd12: char_data = (dot_step >= 2'd2) ? "." : " ";
                    default: char_data = " ";
                endcase
            end
        end else begin
            // Linea 2: Digito del contador centrado en columna 7
            if (char_idx[3:0] == 4'd7) begin
                char_data = 8'h30 + {4'd0, count};
            end else begin
                char_data = " ";
            end
        end
    end

    // FSM de control y refresco continuo
    always @(posedge clk) begin
        if (rst) begin
            state     <= S_INIT_DELAY;
            init_step <= 4'd0;
            delay_cnt <= DELAY_40MS[20:0];
            char_idx  <= 5'd0;
            line_sel  <= 1'b0;
            lcd_start <= 1'b0;
            lcd_data  <= 8'd0;
            lcd_rs    <= 1'b0;
            lcd_nib   <= 1'b0;
        end else begin
            lcd_start <= 1'b0;

            case (state)
                S_INIT_DELAY: begin
                    if (delay_cnt != 21'd0) begin
                        delay_cnt <= delay_cnt - 1'b1;
                    end else if (init_step >= INIT_STEPS[3:0]) begin
                        line_sel <= 1'b0;
                        char_idx <= 5'd0;
                        state    <= S_LINE_ADDR;
                    end else begin
                        state <= S_INIT_CMD;
                    end
                end

                S_INIT_CMD: begin
                    if (!lcd_busy) begin
                        lcd_data  <= init_cmd_data;
                        lcd_rs    <= 1'b0;
                        lcd_nib   <= init_cmd_nib;
                        lcd_start <= 1'b1;
                        state     <= S_INIT_WAIT;
                    end
                end

                S_INIT_WAIT: begin
                    if (lcd_done) begin
                        delay_cnt <= init_cmd_delay;
                        init_step <= init_step + 1'b1;
                        state     <= S_INIT_DELAY;
                    end
                end

                // Establecer direccion DDRAM: 0x80 para linea 1, 0xC0 para linea 2
                S_LINE_ADDR: begin
                    if (!lcd_busy) begin
                        lcd_data  <= line_sel ? 8'hC0 : 8'h80;
                        lcd_rs    <= 1'b0;
                        lcd_nib   <= 1'b0;
                        lcd_start <= 1'b1;
                        char_idx  <= 5'd0;
                        state     <= S_CMD_WAIT;
                    end
                end

                S_CMD_WAIT: begin
                    if (lcd_done) begin
                        state <= S_LINE_DATA;
                    end
                end

                // Transmision serial de los 16 caracteres de la linea actual
                S_LINE_DATA: begin
                    if (!lcd_busy) begin
                        if (char_idx < LCD_COLS[4:0]) begin
                            lcd_data  <= char_data;
                            lcd_rs    <= 1'b1;
                            lcd_nib   <= 1'b0;
                            lcd_start <= 1'b1;
                            char_idx  <= char_idx + 1'b1;
                            state     <= S_CMD_WAIT;
                        end else begin
                            line_sel <= ~line_sel;
                            state    <= S_LINE_ADDR;
                        end
                    end
                end

                default: state <= S_INIT_DELAY;
            endcase
        end
    end

endmodule
