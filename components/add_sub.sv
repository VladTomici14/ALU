//--------------------------------------------------------------------------
// Design Name: Ripple Carry Adder / Subtractor
// File Name: add_sub.sv
// Description: Structural WIDTH-bit ripple-carry adder with subtraction
//              capability. Subtraction is done the classic way: B is
//              conditionally complemented (via xorn_gate) and the same
//              control bit feeds carry-in of bit 0, completing the
//              two's-complement negation. Add and subtract therefore
//              share one identical chain of full_adder cells -
//              no separate datapath, no mux needed.
//
//              Deliberately "easy, not efficient": a plain ripple chain,
//              not carry-lookahead/carry-select/etc.
//
//              Exposes the raw carry chain (Cout, Cmsb_in) so the wrapper
//              modules (alu_add/alu_subtract) can derive C/V flags as
//              simple wire taps instead of recomputing them behaviorally.
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module add_sub #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    input  logic sub, // 0 = A + B, 1 = A - B
    output logic [WIDTH-1:0] Result,
    output logic Cout, // carry out of the MSB
    output logic Cmsb_in // carry into the MSB (for overflow)
);

    logic [WIDTH-1:0] B_eff; // B, conditionally complemented
    logic [WIDTH:0] carry; // carry[0] = cin of bit0, carry[WIDTH] = final cout

    // sub=0 -> B_eff = B (adding). sub=1 -> B_eff = ~B (first half of -B)
    // more precisely, if sub = 0, then every bit of a is XOR'd with 0 => no change, as opposed to XOR'd with 1
    xorn_gate #(WIDTH) b_invert (
        .a(B),
        .b(sub),
        .y(B_eff)
    );

    // sub also feeds cin of bit 0: the "+1" that finishes two's-complement
    // negation, so the chain below computes A - B when sub=1.
    assign carry[0] = sub;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_fa
            full_adder fa (
                .a (A[i]),
                .b (B_eff[i]),
                .cin (carry[i]),
                .sum (Result[i]),
                .cout (carry[i+1])
            );
        end
    endgenerate

    assign Cout = carry[WIDTH];
    assign Cmsb_in = carry[WIDTH-1];

endmodule // add_sub