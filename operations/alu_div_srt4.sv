`timescale 1ns/1ps
// -------------------------------------------------------------------------
// Design Name: Radix-4 Sequential Divider
// File Name: alu_div_srt4.sv
// Description: Sequential unsigned radix-4 divider for 8-bit operands.
//              Operates in 4 cycles, two dividend bits per cycle, and uses
//              a simple shift-subtract datapath that is conceptually similar
//              to the project's other structural sequential components.
// -------------------------------------------------------------------------
module alu_div_srt4 (
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

    state_t      state;
    logic [1:0]  iter;
    logic [11:0] remainder;
    logic [7:0]  quotient;
    logic [9:0]  dividend_ext;
    logic [7:0]  divisor_reg;
    logic [11:0] divisor_ext;
    logic [11:0] next_rem;
    logic [1:0]  q_digit;

    assign Result = quotient;
    assign Z = (Result == 8'b0);
    assign N = Result[7];
    assign V = 1'b0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            iter <= 2'd0;
            remainder <= 12'd0;
            quotient <= 8'd0;
            dividend_ext <= 10'd0;
            divisor_reg <= 8'd0;
            divisor_ext <= 12'd0;
            done <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        divisor_reg <= B;
                        divisor_ext <= {4'd0, B};
                        dividend_ext <= {2'd0, A};
                        remainder <= 12'd0;
                        quotient <= 8'd0;
                        iter <= 2'd0;
                        done <= 1'b0;
                        state <= BUSY;
                    end else begin
                        done <= 1'b1;
                    end
                end

                BUSY: begin
                    if (divisor_reg == 8'd0) begin
                        quotient <= 8'd0;
                        remainder <= 12'd0;
                        done <= 1'b1;
                        state <= IDLE;
                    end else begin
                        next_rem = {remainder[9:0], 2'b00} | {10'd0, dividend_ext[9:8]};
                        dividend_ext <= {dividend_ext[7:0], 2'b00};

                        if (next_rem >= divisor_ext * 3) begin
                            q_digit = 2'd3;
                        end else if (next_rem >= divisor_ext * 2) begin
                            q_digit = 2'd2;
                        end else if (next_rem >= divisor_ext) begin
                            q_digit = 2'd1;
                        end else begin
                            q_digit = 2'd0;
                        end

                        quotient <= quotient + (q_digit << ((3 - iter) * 2));
                        remainder <= next_rem - q_digit * divisor_ext;

                        if (iter == 2'd3) begin
                            done <= 1'b1;
                            state <= IDLE;
                        end else begin
                            iter <= iter + 1'b1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
