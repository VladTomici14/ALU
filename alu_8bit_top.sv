module alu_8bit_top (
    input  logic [7:0] A,          // 8-bit Operand A
    input  logic [7:0] B,          // 8-bit Operand B
    input  logic [3:0] ALU_Sel,    // 4-bit Operation Selector
    output logic [7:0] Result,     // 8-bit Result
    output logic       Z,          // Zero Flag
    output logic       N,          // Negative Flag
    output logic       V           // Overflow Flag
);

    logic [7:0] div_result, and_result, or_result, xor_result, lshift_result, rshift_result;
    logic div_z, div_n, div_v;
    logic and_z, and_n, and_v;
    logic or_z, or_n, or_v;
    logic xor_z, xor_n, xor_v;
    logic lshift_z, lshift_n, lshift_v;
    logic rshift_z, rshift_n, rshift_v;

    // Instantiate Division Module
    alu_div div_inst (
        .A(A),
        .B(B),
        .Result(div_result),
        .Z(div_z),
        .N(div_n),
        .V(div_v)
    );

    // Instantiate AND Module
    alu_and and_inst (
        .A(A),
        .B(B),
        .Result(and_result),
        .Z(and_z),
        .N(and_n),
        .V(and_v)
    );

    // Instantiate OR Module
    alu_or or_inst (
        .A(A),
        .B(B),
        .Result(or_result),
        .Z(or_z),
        .N(or_n),
        .V(or_v)
    );

    // Instantiate XOR Module
    alu_xor xor_inst (
        .A(A),
        .B(B),
        .Result(xor_result),
        .Z(xor_z),
        .N(xor_n),
        .V(xor_v)
    );

    // Instantiate Left Shift Module
    alu_lshift lshift_inst (
        .A(A),
        .B(B),
        .Result(lshift_result),
        .Z(lshift_z),
        .N(lshift_n),
        .V(lshift_v)
    );

    // Instantiate Right Shift Module
    alu_rshift rshift_inst (
        .A(A),
        .B(B),
        .Result(rshift_result),
        .Z(rshift_z),
        .N(rshift_n),
        .V(rshift_v)
    );

    // Multiplexer for Result Selection
    always_comb begin
        case (ALU_Sel)
            4'b0011: begin
                Result = div_result;
                Z = div_z;
                N = div_n;
                V = div_v;
            end
            4'b0100: begin
                Result = and_result;
                Z = and_z;
                N = and_n;
                V = and_v;
            end
            4'b0101: begin
                Result = or_result;
                Z = or_z;
                N = or_n;
                V = or_v;
            end
            4'b0110: begin
                Result = xor_result;
                Z = xor_z;
                N = xor_n;
                V = xor_v;
            end
            4'b0111: begin
                Result = lshift_result;
                Z = lshift_z;
                N = lshift_n;
                V = lshift_v;
            end
            4'b1000: begin
                Result = rshift_result;
                Z = rshift_z;
                N = rshift_n;
                V = rshift_v;
            end
            default: begin
                Result = 8'b0;
                Z = 1'b0;
                N = 1'b0;
                V = 1'b0;
            end
        endcase
    end

endmodule
