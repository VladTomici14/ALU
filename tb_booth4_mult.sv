`timescale 1ns/1ps
module tb_booth4_mult;

    logic clk = 0;
    logic rst_n;
    logic start;
    logic [7:0] A, B;
    logic done;
    logic [15:0] Product;

    booth4_mult dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .A(A), .B(B), .done(done), .Product(Product)
    );

    always #5 clk = ~clk;

    integer errors;
    integer tested;

    task run_one(input [7:0] a, input [7:0] b);
        logic signed [15:0] expected;
        begin
            A = a; B = b;
            expected = $signed(a) * $signed(b);

            // pulse start for one cycle
            @(negedge clk); start = 1;
            @(negedge clk); start = 0;

            // wait for done (with a generous timeout)
            wait (done === 1'b1);

            tested++;
            if (tested % 5000 == 0)
                $display("...progress: %0d vectors tested at t=%0t", tested, $time);

            if (Product !== expected) begin
                errors++;
                if (errors <= 15)
                    $display("MISMATCH A=%0d(signed %0d) B=%0d(signed %0d) got=%0d exp=%0d",
                              a, $signed(a), b, $signed(b), Product, expected);
            end
        end
    endtask

    integer a, b;
    initial begin
        errors = 0;
        tested = 0;
        rst_n = 0; start = 0; A = 0; B = 0;
        repeat (3) @(negedge clk);
        rst_n = 1;
        @(negedge clk);

        // Targeted edge cases first
        run_one(8'd0, 8'd0);
        run_one(8'd127, 8'd127);
        run_one(8'd128, 8'd128);   // -128 * -128 = 16384, biggest positive magnitude
        run_one(8'd127, 8'd128);   // 127 * -128
        run_one(8'd128, 8'd127);
        run_one(8'd1, 8'd255);     // 1 * -1
        run_one(8'd255, 8'd255);   // -1 * -1
        run_one(8'd200, 8'd2);     // the case from tb_alu_top's old "Mult (Truncate)" vector

        // Exhaustive sweep: all 65536 signed 8x8 combinations
        for (a = 0; a < 256; a++) begin
            for (b = 0; b < 256; b++) begin
                run_one(a[7:0], b[7:0]);
            end
        end

        if (errors == 0)
            $display("tb_booth4_mult: ALL %0d VECTORS PASSED", tested);
        else
            $display("tb_booth4_mult: %0d FAILURES out of %0d", errors, tested);

        $finish;
    end

    // Safety timeout in case done never asserts
    initial begin
        #20_000_000;
        $display("TIMEOUT - done never asserted");
        $finish;
    end

endmodule