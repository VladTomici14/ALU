module tb_alu_cli;

    logic       clk;
    logic       rst_n;
    logic       start;
    logic [7:0] A, B, Result;
    logic [3:0] ALU_Sel;
    logic       Z, N, V, done;

    int a_val, b_val, op_val;

    // Drives the modular implementation (alu_8bit_top), which supports
    // the variable-amount shifts and the sequential multiply.
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

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        if (!$value$plusargs("A=%d", a_val)) a_val = 0;
        if (!$value$plusargs("B=%d", b_val)) b_val = 0;
        if (!$value$plusargs("OP=%d", op_val)) op_val = 0;

        A = a_val[7:0];
        B = b_val[7:0];
        ALU_Sel = op_val[3:0];
        start = 0;

        rst_n = 0;
        repeat (3) @(negedge clk);
        rst_n = 1;
        @(negedge clk);

        if (ALU_Sel == 4'b0010) begin
            // Multiply is sequential now - pulse start and wait for done.
            @(negedge clk); start = 1;
            @(negedge clk); start = 0;
            wait (done === 1'b1);
            #1; // let the Result/Z/N/V mux settle
        end else begin
            #1; // every other operation is still purely combinational
        end

        // Single machine-parseable line - easy for the wrapper script to read.
        $display("RESULT=%0d SIGNED=%0d Z=%0d N=%0d V=%0d", Result, $signed(Result), Z, N, V);

        $finish;
    end

endmodule