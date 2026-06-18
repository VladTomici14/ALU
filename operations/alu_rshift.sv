module alu_rshift (
    input  logic [7:0] A,          // 8-bit Operand A
    input  logic [7:0] B,          // 8-bit Shift Amount (A is shifted right by B positions)
    output logic [7:0] Result,     // 8-bit Result
    output logic       Z,          // Zero Flag
    output logic       N,          // Negative Flag
    output logic       V           // Overflow Flag
);

    logic [7:0] rshift_result;

    // Logical Right Shift by B Combinational Logic
    always_comb begin
        if (B >= 8)
            rshift_result = 8'b0;   // shifting an 8-bit value by 8+ moves every bit out
        else
            rshift_result = A >> B;
    end

    // Output assignment
    assign Result = rshift_result;

    // Flag calculations
    assign Z = (rshift_result == 8'b0);
    assign N = rshift_result[7];  // MSB indicates negative in two's complement
    assign V = 1'b0;              // No overflow for shift operation

endmodule