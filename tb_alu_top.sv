module tb_alu_top;

    // Testbench signals
    logic       clk;
    logic       rst_n;
    logic       start;
    logic [7:0] A;
    logic [7:0] B;
    logic [3:0] ALU_Sel;
    logic [7:0] Result;
    logic       Z;
    logic       N;
    logic       V;
    logic       done;

    // Instantiate the modular ALU (Device Under Test)
    alu_8bit_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .Result(Result),
        .Z(Z),
        .N(N),
        .V(V),
        .done(done)
    );

    // Clock generation - only the sequential multiply path needs this;
    // every other operation stays purely combinational and ignores it.
    initial clk = 0;
    always #5 clk = ~clk;

    // Pulses start for one cycle and waits for done. Used only for the
    // multiply vectors below; every other operation keeps the original
    // "set inputs, #10, sample" pattern unchanged.
    task run_multiply(input [7:0] a, input [7:0] b);
        begin
            ALU_Sel = 4'b0010; A = a; B = b;
            @(negedge clk); start = 1;
            @(negedge clk); start = 0;
            wait (done === 1'b1);
            #1; // let the Result/Z/N/V mux fully settle before sampling
        end
    endtask

    // Test sequence - mirrors tb_alu.sv so the monolithic and modular
    // implementations can be checked against the same vectors.
    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("tb_alu_top.vcd");
        $dumpvars(0, tb_alu_top);

        $display("Starting ALU (modular) Simulation...");
        $display("--------------------------------------------------");
        $display(" A    | B    | Sel | Result | Z | N | V | Operation");
        $display("--------------------------------------------------");

        start = 0;
        rst_n = 0;
        repeat (3) @(negedge clk);
        rst_n = 1;
        @(negedge clk);

        // 0. Addition (Normal)
        A = 8'd50; B = 8'd25; ALU_Sel = 4'b0000; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Addition", A, B, ALU_Sel, Result, Z, N, V);

        // 0. Addition (Overflow Trigger: 127 + 1 = 128 -> -128 in signed 8-bit)
        A = 8'd127; B = 8'd1; ALU_Sel = 4'b0000; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Add (Overflow)", A, B, ALU_Sel, $signed(Result), Z, N, V);

        // 1. Subtraction
        A = 8'd100; B = 8'd20; ALU_Sel = 4'b0001; #10;
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Subtraction", A, B, ALU_Sel, Result, Z, N, V);

        // 2. Multiplication (now signed two's-complement and sequential -
        //    pulse start and wait for done instead of just settling)
        run_multiply(8'd10, 8'd5);
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Multiplication", A, B, ALU_Sel, Result, Z, N, V);

        // 2. Multiplication (Truncation: 200 and 2 are now read as signed,
        //    so this is -56*2 = -112, which DOES fit in signed 8 bits.
        //    The truncated low byte is still 144 (truncation is mod-256
        //    either way), but V is now 0, not 1 as it was under the old
        //    unsigned interpretation where 200*2=400 overflowed 8 bits)
        run_multiply(8'd200, 8'd2);
        $display("%4d | %4d | %b | %6d | %b | %b | %b | Mult (Truncate)", A, B, ALU_Sel, Result, Z, N, V);

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

        // 7. Left Shift by 3
        A = 8'b00001111; B = 8'd3; ALU_Sel = 4'b0111; #10;
        $display("%b | %4d | %b | %b | %b | %b | %b | Left Shift (by 3)", A, B, ALU_Sel, Result, Z, N, V);

        // 7. Left Shift by 0 (no movement)
        A = 8'b00001111; B = 8'd0; ALU_Sel = 4'b0111; #10;
        $display("%b | %4d | %b | %b | %b | %b | %b | Left Shift (by 0)", A, B, ALU_Sel, Result, Z, N, V);

        // 7. Left Shift by >= 8 (every bit shifted out -> 0)
        A = 8'b00001111; B = 8'd9; ALU_Sel = 4'b0111; #10;
        $display("%b | %4d | %b | %b | %b | %b | %b | Left Shift (B>=8)", A, B, ALU_Sel, Result, Z, N, V);

        // 8. Right Shift by 3
        A = 8'b11110000; B = 8'd3; ALU_Sel = 4'b1000; #10;
        $display("%b | %4d | %b | %b | %b | %b | %b | Right Shift (by 3)", A, B, ALU_Sel, Result, Z, N, V);

        // 8. Right Shift by 0 (no movement)
        A = 8'b11110000; B = 8'd0; ALU_Sel = 4'b1000; #10;
        $display("%b | %4d | %b | %b | %b | %b | %b | Right Shift (by 0)", A, B, ALU_Sel, Result, Z, N, V);

        // 8. Right Shift by exactly 8 (every bit shifted out -> 0)
        A = 8'b11110000; B = 8'd8; ALU_Sel = 4'b1000; #10;
        $display("%b | %4d | %b | %b | %b | %b | %b | Right Shift (B==8)", A, B, ALU_Sel, Result, Z, N, V);

        $display("--------------------------------------------------");
        $display("Simulation Complete.");

        $finish; // End simulation
    end

endmodule