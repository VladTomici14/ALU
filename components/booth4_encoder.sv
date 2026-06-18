//--------------------------------------------------------------------------
// Design Name: Radix-4 Booth window encoder
// File Name: booth4_encoder.sv
// Description: Decodes a 3-bit overlapping window {w2,w1,w0} of the
//              multiplier (w2 = b[2i+1], w1 = b[2i], w0 = b[2i-1]) into
//              the radix-4 Booth digit, expressed as three control lines:
//                one    - magnitude is 1 (use A)
//                two    - magnitude is 2 (use 2A)
//                negate - digit is negative
//              one and two are mutually exclusive; when both are 0 the
//              digit is 0 regardless of negate.
//
//              Truth table (w2 w1 w0 -> digit):
//                000 -> 0   001 -> +1   010 -> +1   011 -> +2
//                100 -> -2  101 -> -1   110 -> -1   111 -> 0
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module booth4_encoder (
    input  logic w2,
    input  logic w1,
    input  logic w0,
    output logic one,
    output logic two,
    output logic negate
);

    logic nw2, nw1, nw0;
    logic two_pos, two_neg;
    logic w1_and_w0, nw1_and_nw0;

    not_gate inv2 (.a(w2), .y(nw2));
    not_gate inv1 (.a(w1), .y(nw1));
    not_gate inv0 (.a(w0), .y(nw0));

    xor2_gate one_xor (.a(w1), .b(w0), .y(one));

    and2_gate and_w1w0 (.a(w1),  .b(w0),  .y(w1_and_w0));
    and2_gate and_nw1nw0 (.a(nw1), .b(nw0), .y(nw1_and_nw0));

    and3_gate and_two_pos (.a(w1_and_w0),   .b(nw2), .c(1'b1), .y(two_pos)); // 011
    and3_gate and_two_neg (.a(nw1_and_nw0), .b(w2),  .c(1'b1), .y(two_neg)); // 100

    or2_gate or_two (.a(two_pos), .b(two_neg), .y(two));

    assign negate = w2;

endmodule // booth4_encoder