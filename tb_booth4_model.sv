`timescale 1ns/1ps

// This TB only checks that the actual Booth Radix 4 algorithm produces the same result as the actual '*' operand
// It does not check OUR Booth Radix 4 implementation

module tb_booth4_model;

    function automatic signed [15:0] booth4_ref(input signed [7:0] a, input signed [7:0] b);
        logic signed [9:0] M;
        logic signed [9:0] M2;
        logic signed [18:0] CQ; // {AC[9:0], QR[8:0]}
        int i;
        logic w2, w1, w0;
        logic one, two, negate;
        logic signed [9:0] PPmag, PP;
        logic signed [9:0] AC;
        logic [8:0] QR;
        begin
            M  = {{2{a[7]}}, a};
            M2 = M <<< 1;
            AC = 10'sd0;
            QR = {b, 1'b0};
            for (i = 0; i < 4; i++) begin
                w2 = QR[2]; w1 = QR[1]; w0 = QR[0];
                one    = w1 ^ w0;
                two    = (w1 & w0 & ~w2) | (~w1 & ~w0 & w2);
                negate = w2;
                PPmag = two ? M2 : (one ? M : 10'sd0);
                PP    = negate ? -PPmag : PPmag;
                AC    = AC + PP;
                CQ    = {AC, QR};
                CQ    = CQ >>> 2;
                AC    = CQ[18:9];
                QR    = CQ[8:0];
            end
            booth4_ref = {AC, QR[8:1]}; // drop the appended bit-(-1), keep 16 bits
        end
    endfunction

    int errors;
    integer a, b;
    logic signed [15:0] got, expected;

    initial begin
        errors = 0;
        for (a = -128; a < 128; a++) begin
            for (b = -128; b < 128; b++) begin
                got = booth4_ref(a[7:0], b[7:0]);
                expected = a * b;
                if (got !== expected) begin
                    errors++;
                    if (errors <= 10)
                        $display("MISMATCH a=%0d b=%0d got=%0d expected=%0d", a, b, got, expected);
                end
            end
        end
        if (errors == 0)
            $display("MODEL OK: all 65536 combinations match");
        else
            $display("MODEL FAIL: %0d mismatches", errors);
        $finish;
    end
endmodule