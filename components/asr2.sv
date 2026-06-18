//--------------------------------------------------------------------------
// Design Name: Arithmetic shift right by 2
// File Name: asr2.sv
// Description: Structural (pure rewiring) arithmetic right shift by 2 bits.
//              Replicates the sign bit twice into the vacated top bits,
//              same idea as the project's existing lshift.sv but for a
//              fixed 2-bit right shift. Used to shift the combined
//              {AC,QR} register pair in the radix-4 Booth multiplier.
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module asr2 #(parameter WIDTH = 19) (
    input  logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
);

    assign out = {in[WIDTH-1], in[WIDTH-1], in[WIDTH-1:2]};

endmodule // asr2