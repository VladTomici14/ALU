// module alu_subtract (
//     input logic [7:0] A, // 8-bit Minuend
//     input logic [7:0] B, // 8-bit Subtrahend
//     output logic [7:0] Result, // 8-bit Result
//     output logic Z, // Zero Flag
//     output logic N, // Negative Flag (MSB of result)
//     output logic C, // Borrow Flag (unsigned underflow, A < B)
//     output logic V // Overflow Flag (signed overflow)
// );
//     logic [7:0] sub_result;

//     // Subtraction Combinational Logic
//     always_comb begin
//         sub_result = A - B;
//     end

//     // Output assignment
//     assign Result = sub_result;

//     // Flag calculations
//     assign Z = (sub_result == 8'b0);
//     assign N = sub_result[7];
//     assign C = (A < B); // borrow occurred, A could not cover B
//     assign V = (A[7] != B[7]) && (sub_result[7] != A[7]); // signed overflow
    
// endmodule

module alu_subtract (
    input logic [7:0] A, // 8-bit Minuend
    input logic [7:0] B, // 8-bit Subtrahend
    output logic [7:0] Result, // 8-bit Result
    output logic Z, // Zero Flag
    output logic N, // Negative Flag (MSB of result)
    output logic C, // Borrow Flag (unsigned underflow, A < B)
    output logic V  // Overflow Flag (signed overflow)
);
    logic cout;
    logic cmsb_in;

    // Same structural ripple-carry chain as alu_add, just wired for
    // subtraction (sub = 1): B is complemented and cin of bit0 is set,
    // which is exactly A + (~B + 1) = A - B.
    add_sub #(.WIDTH(8)) core (
        .A (A),
        .B (B),
        .sub (1'b1),
        .Result  (Result),
        .Cout (cout),
        .Cmsb_in (cmsb_in)
    );

    assign Z = (Result == 8'b0);
    assign N = Result[7];
    // Borrow is just the complement of the chain's carry-out: when A >= B
    // the two's-complement add produces a carry out (no borrow); when
    // A < B it doesn't (borrow occurred). No separate comparator needed.
    assign C = ~cout;
    assign V = cmsb_in ^ cout;

endmodule