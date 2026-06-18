`timescale 1ns/1ps
module tb_add_sub;
    logic [7:0] A, B;
    logic sub;
    logic [7:0] Result;
    logic Cout, Cmsb_in, V, C_borrow;
    integer errors;

    add_sub #(.WIDTH(8)) dut (.A(A), .B(B), .sub(sub), .Result(Result), .Cout(Cout), .Cmsb_in(Cmsb_in));
    assign V = Cmsb_in ^ Cout;
    assign C_borrow = ~Cout;

    task check_add(input [7:0] a, b);
        logic [8:0] expected_wide;
        logic exp_v;
        begin
            A = a; B = b; sub = 0; #1;
            expected_wide = {1'b0,a} + {1'b0,b};
            exp_v = (a[7]==b[7]) && (Result[7]!=a[7]);
            if (Result !== expected_wide[7:0] || Cout !== expected_wide[8] || V !== exp_v) begin
                errors++;
                $display("ADD FAIL a=%0d b=%0d -> got Result=%0d Cout=%0b V=%0b | exp Result=%0d Cout=%0b V=%0b",
                          a,b,Result,Cout,V, expected_wide[7:0], expected_wide[8], exp_v);
            end
        end
    endtask

    task check_sub(input [7:0] a, b);
        logic [7:0] expected_result;
        logic exp_borrow;
        logic exp_v;
        begin
            A = a; B = b; sub = 1; #1;
            expected_result = a - b;
            exp_borrow = (a < b);
            exp_v = (a[7]!=b[7]) && (Result[7]!=a[7]);
            if (Result !== expected_result || C_borrow !== exp_borrow || V !== exp_v) begin
                errors++;
                $display("SUB FAIL a=%0d b=%0d -> got Result=%0d Borrow=%0b V=%0b | exp Result=%0d Borrow=%0b V=%0b",
                          a,b,Result,C_borrow,V, expected_result, exp_borrow, exp_v);
            end
        end
    endtask

    initial begin
        errors = 0;
        // Targeted edge cases
        check_add(8'd0, 8'd0);
        check_add(8'd255, 8'd1);     // unsigned wrap, Cout=1
        check_add(8'd127, 8'd1);     // signed overflow (+/+ -> -)
        check_add(8'd128, 8'd128);   // signed overflow (-/- -> +), unsigned Cout=1
        check_sub(8'd0, 8'd0);
        check_sub(8'd5, 8'd10);      // borrow case, A<B
        check_sub(8'd10, 8'd5);      // no borrow
        check_sub(8'd128, 8'd1);     // -128 - 1 -> signed overflow
        check_sub(8'd127, 8'd255);   // 127 - (-1) -> signed overflow
        check_sub(8'd0, 8'd1);       // 0 - 1 -> borrow, no signed overflow

        // Broad sweep against a behavioral reference
        for (int a = 0; a < 256; a += 17) begin
            for (int b = 0; b < 256; b += 13) begin
                check_add(a[7:0], b[7:0]);
                check_sub(a[7:0], b[7:0]);
            end
        end

        if (errors == 0)
            $display("tb_add_sub: ALL CHECKS PASSED");
        else
            $display("tb_add_sub: %0d FAILURES", errors);
        $finish;
    end
endmodule