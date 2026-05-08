module tb_alu;

    // Testbench signals
    logic [7:0] A;
    logic [7:0] B;
    logic [3:0] ALU_Sel;
    logic [7:0] Result;
    logic       Z;
    logic       N;
    logic       V;

    // Instantiate the ALU (Device Under Test)
    alu_8bit dut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .Result(Result),
        .Z(Z),
        .N(N),
        .V(V)
    );

    // Test sequence
    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu);

        $display("Starting ALU Simulation...");
        $display("--------------------------------------------------");
        $display(" A    | B    | Sel | Result | Z | N | V | Operation");
        $display("--------------------------------------------------");

        // 0. Addition (Normal)
        A = 8'd50; B = 8'd25; ALU_Sel = 4'b0000; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Addition", A, B, ALU_Sel, Result, Z, N, V);

        // 0. Addition (Overflow Trigger: 127 + 1 = 128 -> -128 in signed 8-bit)
        A = 8'd127; B = 8'd1; ALU_Sel = 4'b0000; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Add (Overflow)", A, B, ALU_Sel, $signed(Result), Z, N, V);

        // 1. Subtraction
        A = 8'd100; B = 8'd20; ALU_Sel = 4'b0001; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Subtraction", A, B, ALU_Sel, Result, Z, N, V);

        // 2. Multiplication
        A = 8'd10; B = 8'd5; ALU_Sel = 4'b0010; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Multiplication", A, B, ALU_Sel, Result, Z, N, V);

        // 3. Division
        A = 8'd100; B = 8'd10; ALU_Sel = 4'b0011; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Division", A, B, ALU_Sel, Result, Z, N, V);

        // 3. Division by Zero
        A = 8'd50; B = 8'd0; ALU_Sel = 4'b0011; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Div by Zero", A, B, ALU_Sel, Result, Z, N, V);

        // 4. Bitwise AND
        A = 8'b11110000; B = 8'b10101010; ALU_Sel = 4'b0100; #10;
        $display("%b | %b | %b | %b | %b | %b | %b | AND", A, B, ALU_Sel, Result, Z, N, V);

        // 5. Bitwise OR
        A = 8'b11110000; B = 8'b00001111; ALU_Sel = 4'b0101; #10;
        $display("%b | %b | %b | %b | %b | %b | %b | OR", A, B, ALU_Sel, Result, Z, N, V);

        // 6. Bitwise XOR
        A = 8'b11110000; B = 8'b11111111; ALU_Sel = 4'b0110; #10;
        $display("%b | %b | %b | %b | %b | %b | %b | XOR", A, B, ALU_Sel, Result, Z, N, V);

        // 7. Left Shift
        A = 8'b00001111; B = 8'd0; ALU_Sel = 4'b0111; #10;
        $display("%b | ---- | %b | %b | %b | %b | %b | Left Shift", A, ALU_Sel, Result, Z, N, V);

        // 8. Right Shift
        A = 8'b11110000; B = 8'd0; ALU_Sel = 4'b1000; #10;
        $display("%b | ---- | %b | %b | %b | %b | %b | Right Shift", A, ALU_Sel, Result, Z, N, V);

        $display("--------------------------------------------------");
        $display("Simulation Complete.");
        
        $finish; // End simulation
    end

endmodule