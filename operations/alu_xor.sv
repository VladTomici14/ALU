module alu_xor (
    input  logic [7:0] A,          // 8-bit Operand A
    input  logic [7:0] B,          // 8-bit Operand B
    output logic [7:0] Result,     // 8-bit Result
    output logic       Z,          // Zero Flag
    output logic       N,          // Negative Flag
    output logic       V           // Overflow Flag
);

    logic [7:0] xor_result;

    // Bitwise XOR Combinational Logic
    always_comb begin
        xor_result = A ^ B;
    end

    // Output assignment
    assign Result = xor_result;

    // Flag calculations
    assign Z = (xor_result == 8'b0);
    assign N = xor_result[7];     // MSB indicates negative in two's complement
    assign V = 1'b0;              // No overflow for XOR operation

endmodule
