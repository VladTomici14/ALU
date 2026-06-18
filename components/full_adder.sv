//--------------------------------------------------------------------------
// Design Name: Full Adder
// File Name: full_adder.sv
// Description: 1-bit full adder cell, built from gate primitives.
//              sum  = a ^ b ^ cin
//              cout = (a & b) | (cin & (a ^ b))
//              The (a ^ b) term is computed once and shared between the
//              sum and carry paths, same trick a hand-built FA would use.
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);

    logic a_xor_b;
    logic a_and_b;
    logic cin_and_axorb;

    xor2_gate xor_ab (.a(a), .b(b), .y(a_xor_b));
    xor2_gate xor_sum (.a(a_xor_b), .b(cin), .y(sum));

    and2_gate and_ab (.a(a), .b(b), .y(a_and_b));
    and2_gate and_cin (.a(cin), .b(a_xor_b), .y(cin_and_axorb));

    or2_gate or_cout (.a(a_and_b), .b(cin_and_axorb), .y(cout));

endmodule // full_adder