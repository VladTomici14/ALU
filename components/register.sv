//--------------------------------------------------------------------------
// Design Name: Register
// File Name: register.sv
// Description: Implementation of a n-bit register with LS/RS
// Version History
// * July 1, 2025 (sebastian ardelean): Finished the implementation 
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module register #(parameter WIDTH = 8) (
    input logic              clk,
    input logic              rst_n,
    input logic              load_en,
    input logic              shift_en,
    input logic              sr,
    input logic              sl,
    input logic              shift_dir, //0 = left shift, 1 = right shift
    input logic [WIDTH-1:0]  d,
    output logic [WIDTH-1:0] q
);

    logic [WIDTH-1:0] shift_mux_out;
    logic [WIDTH-1:0] load_mux_out;

    logic left_shift_wire;
    logic right_shift_wire;

    assign left_shift_wire = ~shift_dir;
    assign right_shift_wire = shift_dir;
    
    genvar i;
    
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_reg
            logic shift_src_left;
            logic shift_src_right;
            logic right_wire;
            logic left_wire;
            
        logic shift_src;
            assign shift_src_left = (i == 0) ? sl : q[i - 1];
            assign shift_src_right = (i == WIDTH - 1) ? sr : q[i+1];
            
            and2_gate and_right (
                                .a(shift_src_right),
                                .b(right_shift_wire),
                                .y(right_wire)
                                );

            and2_gate and_left (
                                .a(shift_src_left),
                                .b(left_shift_wire),
                                .y(left_wire)
                                );
            
            or2_gate or_shift (.a(right_wire),
                            .b(left_wire),
                            .y(shift_src)
                            );
            
            mux2 #(1) mux_shift(
                    .d0(q[i]),
                    .d1(shift_src),
                    .s(shift_en),
                    .y(shift_mux_out[i]));
            
        mux2 #(1) mux_load (
                    .d0(shift_mux_out[i]),
                    .d1(d[i]),
                    .s(load_en),
                    .y(load_mux_out[i]));
        
        dff ff_inst (
                        .clk(clk),
                        .rst_n(rst_n),
                        .d(load_mux_out[i]),
                        .q(q[i])
                );
        end
    endgenerate

endmodule //register