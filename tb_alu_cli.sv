module tb_alu_cli;

    logic [7:0] A, B, Result;
    logic [3:0] ALU_Sel;
    logic Z, N, V;

    int a_val, b_val, op_val;

    // Drives the modular implementation (alu_8bit_top), which supports
    // the variable-amount shifts.
    alu_8bit_top dut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .Result(Result),
        .Z(Z),
        .N(N),
        .V(V)
    );

    initial begin
        if (!$value$plusargs("A=%d", a_val)) a_val = 0;
        if (!$value$plusargs("B=%d", b_val)) b_val = 0;
        if (!$value$plusargs("OP=%d", op_val)) op_val = 0;

        A = a_val[7:0];
        B = b_val[7:0];
        ALU_Sel = op_val[3:0];

        #1; // let combinational logic settle

        // Single machine-parseable line - easy for the wrapper script to read.
        $display("RESULT=%0d SIGNED=%0d Z=%0d N=%0d V=%0d", Result, $signed(Result), Z, N, V);

        $finish;
    end

endmodule