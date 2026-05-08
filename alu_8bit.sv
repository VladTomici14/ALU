module alu_8bit (
    input  logic [7:0] A,          // 8-bit Operand A
    input  logic [7:0] B,          // 8-bit Operand B
    input  logic [3:0] ALU_Sel,    // 4-bit Operation Selector
    output logic [7:0] Result,     // 8-bit Result
    output logic       Z,          // Zero Flag
    output logic       N,          // Negative Flag
    output logic       V           // Overflow Flag
);

    logic [7:0] alu_result;

    // Core ALU Combinational Logic
    always_comb begin
        alu_result = 8'b0; // Default assignment

        case (ALU_Sel)
            4'b0000: alu_result = A + B;          // Addition
            4'b0001: alu_result = A - B;          // Subtraction
            4'b0010: alu_result = A * B;          // Multiplication
            4'b0011: begin                        // Division
                if (B != 0) alu_result = A / B;
                else        alu_result = 8'b0;    // Safe divide-by-zero fallback
            end
            4'b0100: alu_result = A & B;          // Bitwise AND
            4'b0101: alu_result = A | B;          // Bitwise OR
            4'b0110: alu_result = A ^ B;          // Bitwise XOR
            4'b0111: alu_result = A << 1;         // Logical Left Shift
            4'b1000: alu_result = A >> 1;         // Logical Right Shift
            default: alu_result = 8'b0;
        endcase
    end

    // Output assignment
    assign Result = alu_result;

    // Flag calculations
    assign Z = (alu_result == 8'b0);
    assign N = alu_result[7]; // MSB indicates negative in two's complement

    // Overflow logic (V) for signed addition and subtraction
    always_comb begin
        V = 1'b0; 
        if (ALU_Sel == 4'b0000) begin 
            // Add Overflow: (+ A) + (+ B) = (- Res) OR (- A) + (- B) = (+ Res)
            V = (~A[7] & ~B[7] & alu_result[7]) | (A[7] & B[7] & ~alu_result[7]);
        end else if (ALU_Sel == 4'b0001) begin 
            // Sub Overflow: (+ A) - (- B) = (- Res) OR (- A) - (+ B) = (+ Res)
            V = (~A[7] & B[7] & alu_result[7]) | (A[7] & ~B[7] & ~alu_result[7]);
        end
    end

endmodule