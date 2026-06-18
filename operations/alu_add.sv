// module alu_add (
//     input logic [7:0] A,
//     input logic [7:0] B,
//     output logic [7:0] Result,
//     output logic Z, // Zero Flag
//     output logic N, // Negative Flag
//     output logic C, // Carry out
//     output logic V // Overflow Flag
// );
//     logic [8:0] sum_wide; // sum_wide on 9 bits to account for possible carry out
//     logic [7:0] add_result;

//     always_comb begin
//         sum_wide   = {1'b0, A} + {1'b0, B}; // 
//         add_result = sum_wide[7:0];
//     end

//     assign Result = add_result;
//     assign Z = (add_result == 8'b0);
//     assign N = add_result[7];
//     assign C = sum_wide[8];
//     assign V = (A[7] == B[7]) && (add_result[7] != A[7]); // sign bits of A and B are the same and sign bit of result is different
    
// endmodule

module alu_add (
    input logic [7:0] A,
    input logic [7:0] B,
    output logic [7:0] Result,
    output logic Z, // Zero Flag
    output logic N, // Negative Flag
    output logic C, // Carry out
    output logic V  // Overflow Flag
);
    logic cout;
    logic cmsb_in;

    // Delegates to the structural ripple-carry adder/subtractor, wired
    // for addition (sub = 0).
    add_sub #(.WIDTH(8)) core (
        .A (A),
        .B (B),
        .sub (1'b0),
        .Result (Result),
        .Cout (cout),
        .Cmsb_in (cmsb_in)
    );

    assign Z = (Result == 8'b0);
    assign N = Result[7];
    assign C = cout;                 // carry out of bit 7
    assign V = cmsb_in ^ cout;        // signed overflow: carry into MSB != carry out of MSB

endmodule