`timescale 1ns/1ps
// -------------------------------------------------------------------------
// Design Name: Radix-2 Sequential Divider
// File Name: alu_div_srt2.sv
// Description: Sequential unsigned radix-2 divider for 8-bit operands.
//              Executes in 8 cycles, shifting the dividend bit-by-bit and
//              selecting a quotient bit each cycle. This matches the project
//              style of a small FSM-driven sequential datapath.
// -------------------------------------------------------------------------
module alu_div_srt2 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [7:0]  A,
    input  logic [7:0]  B,
    output logic [7:0]  Result,
    output logic        Z,
    output logic        N,
    output logic        V,
    output logic        done
);

    typedef enum logic [1:0] {IDLE = 2'b00, BUSY = 2'b01} state_t;

    state_t     state;
    logic [2:0] bit_index;
    logic [8:0] remainder;
    logic [7:0] quotient;
    logic [7:0] dividend_reg;
    logic [7:0] divisor_reg;

    assign Result = quotient;
    assign Z = (Result == 8'b0);
    assign N = Result[7];
    assign V = 1'b0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_index <= 3'd0;
            remainder <= 9'd0;
            quotient <= 8'd0;
            dividend_reg <= 8'd0;
            divisor_reg <= 8'd0;
            done <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        dividend_reg <= A;
                        divisor_reg <= B;
                        remainder <= 9'd0;
                        quotient <= 8'd0;
                        bit_index <= 3'd0;
                        done <= 1'b0;
                        state <= BUSY;
                    end else begin
                        done <= 1'b1;
                    end
                end

                BUSY: begin
                    if (divisor_reg == 8'd0) begin
                        quotient <= 8'd0;
                        remainder <= 9'd0;
                        done <= 1'b1;
                        state <= IDLE;
                    end else begin
                        remainder <= {remainder[7:0], dividend_reg[7-bit_index]};
                        if ({1'b0, remainder[7:0], dividend_reg[7-bit_index]} >= {1'b0, divisor_reg}) begin
                            quotient[7-bit_index] <= 1'b1;
                            remainder <= {remainder[7:0], dividend_reg[7-bit_index]} - {1'b0, divisor_reg};
                        end else begin
                            quotient[7-bit_index] <= 1'b0;
                        end

                        if (bit_index == 3'd7) begin
                            done <= 1'b1;
                            state <= IDLE;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
