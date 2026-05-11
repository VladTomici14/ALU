module alu_or (
    input  logic [7:0] A,          // 8-bit Operand A
    input  logic [7:0] B,          // 8-bit Operand B
    output logic [7:0] Result,     // 8-bit Result
    output logic       Z,          // Zero Flag
    output logic       N,          // Negative Flag
    output logic       V           // Overflow Flag
);

    logic [7:0] or_result;

    // Bitwise OR Combinational Logic
    always_comb begin
        or_result = A | B;
    end

    // Output assignment
    assign Result = or_result;

    // Flag calculations
    assign Z = (or_result == 8'b0);
    assign N = or_result[7];      // MSB indicates negative in two's complement
    assign V = 1'b0;              // No overflow for OR operation

endmodule
