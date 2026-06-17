module alu_lshift (
    input  logic [7:0] A,          // 8-bit Operand A
    input  logic [7:0] B,          // 8-bit Shift Amount (A is shifted left by B positions)
    output logic [7:0] Result,     // 8-bit Result
    output logic       Z,          // Zero Flag
    output logic       N,          // Negative Flag
    output logic       V           // Overflow Flag
);

    logic [7:0] lshift_result;

    // Logical Left Shift by B Combinational Logic
    always_comb begin
        if (B >= 8)
            lshift_result = 8'b0;   // shifting an 8-bit value by 8+ moves every bit out
        else
            lshift_result = A << B;
    end

    // Output assignment
    assign Result = lshift_result;

    // Flag calculations
    assign Z = (lshift_result == 8'b0);
    assign N = lshift_result[7];  // MSB indicates negative in two's complement
    assign V = 1'b0;              // No overflow for shift operation

endmodule