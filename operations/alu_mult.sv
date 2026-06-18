// module alu_mult (
//     input  logic [7:0] A, // 8-bit Multiplicand
//     input  logic [7:0] B, // 8-bit Multiplier
//     output logic [7:0] Result, // 8-bit (truncated) Result
//     output logic Z, // Zero Flag
//     output logic N, // Negative Flag (MSB of truncated result)
//     output logic V // "Overflow" Flag - in this case checks if the product truncated on 8 bits lost real information
// );
//     logic [15:0] mult_wide; // full-width product, avoids implicit truncation
//     logic [7:0]  mult_result; // low byte of the product, what gets output

//     // Multiplication Combinational Logic
//     always_comb begin
//         mult_wide = A * B; // full 16-bit unsigned product
//         mult_result = mult_wide[7:0];
//     end

//     // Output assignment
//     assign Result = mult_result;

//     // Flag calculations
//     assign Z = (mult_result == 8'b0);
//     assign N = mult_result[7]; // MSB of the truncated byte
//     assign V = (mult_wide[15:8] != 8'b0); // true product didn't fit in 8 bits
// endmodule

//--------------------------------------------------------------------------
// Design Name: ALU Multiply (signed, sequential)
// File Name: alu_mult.sv
// Description: Wraps the structural radix-4 Booth multiplier (booth4_mult).
//              Behavior change from the prior version: this interprets A
//              and B as signed two's-complement (the prior version treated
//              them as unsigned). The truncated low-byte Result is
//              numerically identical either way (two's complement mod 2^8
//              == unsigned mod 2^8); only the meaning of V changes, from
//              "the upper byte is nonzero" to "the true signed product
//              doesn't fit in 8 bits". This operation is now sequential:
//              pulse start for one cycle, then wait for done before
//              trusting Result/Z/N/V.
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module alu_mult (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic [7:0] A,        // 8-bit Multiplicand (signed)
    input  logic [7:0] B,        // 8-bit Multiplier (signed)
    output logic [7:0] Result,   // 8-bit (truncated) Result, valid when done = 1
    output logic Z,        // Zero Flag
    output logic N,        // Negative Flag (MSB of truncated result)
    output logic V,        // true signed product doesn't fit in 8 bits
    output logic done
);

    logic [15:0] product; // full 16-bit signed product, valid when done = 1

    booth4_mult core (
        .clk(clk), .rst_n(rst_n), .start(start),
        .A(A), .B(B),
        .done(done),
        .Product(product)
    );

    assign Result = product[7:0];
    assign Z = (Result == 8'b0);
    assign N = Result[7];
    assign V = (product[15:8] != {8{product[7]}});

endmodule