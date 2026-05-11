module alu_div (
    input  logic [7:0] A,          // 8-bit Dividend
    input  logic [7:0] B,          // 8-bit Divisor
    output logic [7:0] Result,     // 8-bit Result
    output logic       Z,          // Zero Flag
    output logic       N,          // Negative Flag
    output logic       V           // Overflow Flag
);

    logic [7:0] div_result;

    // Division Combinational Logic
    always_comb begin
        if (B != 0) 
            div_result = A / B;
        else 
            div_result = 8'b0;    // Safe divide-by-zero fallback
    end

    // Output assignment
    assign Result = div_result;

    // Flag calculations
    assign Z = (div_result == 8'b0);
    assign N = div_result[7];     // MSB indicates negative in two's complement
    assign V = 1'b0;              // No overflow for division

endmodule
