module alu_mult (
    input  logic [7:0] A, // 8-bit Multiplicand
    input  logic [7:0] B, // 8-bit Multiplier
    output logic [7:0] Result, // 8-bit (truncated) Result
    output logic Z, // Zero Flag
    output logic N, // Negative Flag (MSB of truncated result)
    output logic V // "Overflow" Flag - in this case checks if the product truncated on 8 bits lost real information
);
    logic [15:0] mult_wide; // full-width product, avoids implicit truncation
    logic [7:0]  mult_result; // low byte of the product, what gets output

    // Multiplication Combinational Logic
    always_comb begin
        mult_wide = A * B; // full 16-bit unsigned product
        mult_result = mult_wide[7:0];
    end

    // Output assignment
    assign Result = mult_result;

    // Flag calculations
    assign Z = (mult_result == 8'b0);
    assign N = mult_result[7]; // MSB of the truncated byte
    assign V = (mult_wide[15:8] != 8'b0); // true product didn't fit in 8 bits
endmodule