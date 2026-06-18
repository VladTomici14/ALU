//--------------------------------------------------------------------------
// Design Name: Radix-4 Booth Multiplier
// File Name: booth4_mult.sv
// Description: Sequential structural radix-4 Booth multiplier for 8-bit
//              signed (two's-complement) operands. 4 iterations (one per
//              2 bits of B), each: decode a 3-bit window of B via
//              booth4_encoder, pick 0/A/2A via mux2, add/subtract it into
//              the accumulator via the reused add_sub component, then
//              arithmetic-shift the combined {AC,QR} pair right by 2 via
//              asr2. M/AC/QR live in the project's existing register.sv,
//              always exercised through its load_en/d path (shift_en is
//              never used here - the 2-bit shift is supplied externally
//              by asr2 instead of register.sv's native 1-bit shifter).
//
//              Widths: M and AC are 10 bits (8-bit operand + 2 guard bits,
//              the minimum needed to hold +-2A without overflow). QR is
//              9 bits (8-bit multiplier + 1 appended bit-(-1), per the
//              standard radix-4 Booth recoding). Verified against an
//              exhaustive 65536-vector behavioral model before being
//              built structurally - see tb_booth4_model.sv.
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module booth4_mult (
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [7:0] A,        // multiplicand
    input logic [7:0] B,        // multiplier
    output logic done,
    output logic [15:0] Product   // valid when done = 1
);

    logic in_load, in_step, in_shift;
    logic counter_is_3;

    cu_booth4 fsm (
        .clk (clk),
        .rst_n (rst_n),
        .start (start),
        .counter_is_3 (counter_is_3),
        .in_load (in_load),
        .in_step (in_step),
        .in_shift (in_shift),
        .done (done)
    );

    // Iteration counter (reused, locally re-armed)
    // counter_nbits has no dedicated clear input; holding its own rst_n
    // low for the one cycle we're in LOAD synchronously clears it back to
    // 0 at the start of every multiply, without modifying that component.
    logic [1:0] counter_o;
    logic counter_rst_n;
    assign counter_rst_n = rst_n & ~in_load;

    counter_nbits #(.WIDTH(2)) iter_counter (
        .clk(clk),
        .rst_n (counter_rst_n),
        .en (in_shift),
        .count (counter_o)
    );
    and2_gate counter_check (.a(counter_o[0]), .b(counter_o[1]), .y(counter_is_3));

    // M register: sign-extended multiplicand
    logic [9:0] M_d, M_q;
    assign M_d = {A[7], A[7], A};

    register #(.WIDTH(10)) M_reg (
        .clk(clk), .rst_n(rst_n),
        .load_en(in_load), .shift_en(1'b0), .sr(1'b0), .sl(1'b0), .shift_dir(1'b0),
        .d(M_d), .q(M_q)
    );

    logic [9:0] M2;
    assign M2 = {M_q[8:0], 1'b0}; // 2A, safe because M_q carries 2 sign guard bits

    // QR register: multiplier + appended bit-(-1)
    logic [8:0] QR_d, QR_q, QR_shifted;

    mux2 #(9) qr_mux (.d0(QR_shifted), .d1({B, 1'b0}), .s(in_load), .y(QR_d));

    register #(.WIDTH(9)) QR_reg (
        .clk(clk), .rst_n(rst_n),
        .load_en(in_load | in_shift), .shift_en(1'b0), .sr(1'b0), .sl(1'b0), .shift_dir(1'b0),
        .d(QR_d), .q(QR_q)
    );

    // Booth4 window decode
    logic one, two, negate, sel;

    booth4_encoder enc (
        .w2(QR_q[2]), .w1(QR_q[1]), .w0(QR_q[0]),
        .one(one), .two(two), .negate(negate)
    );
    or2_gate sel_or (.a(one), .b(two), .y(sel));

    // Partial product magnitude: 0, A, or 2A
    logic [9:0] pp_stage1, pp_mag;
    mux2 #(10) pp_mux1 (.d0(M_q), .d1(M2), .s(two), .y(pp_stage1));
    mux2 #(10) pp_mux2 (.d0(10'b0), .d1(pp_stage1), .s(sel), .y(pp_mag));

    // AC register: running accumulator
    logic [9:0] AC_d, AC_q, AC_added, AC_shifted_part;
    logic add_cout, add_cmsb; // unused mid-computation; final V comes from Product

    add_sub #(.WIDTH(10)) accumulate (
        .A(AC_q), .B(pp_mag), .sub(negate),
        .Result(AC_added), .Cout(add_cout), .Cmsb_in(add_cmsb)
    );

    // Combined AC:QR shifter (the dedicated 2-bit shifter)
    logic [18:0] cq_in, cq_out;
    assign cq_in = {AC_q, QR_q};

    asr2 #(.WIDTH(19)) shifter (.in(cq_in), .out(cq_out));

    assign AC_shifted_part = cq_out[18:9];
    assign QR_shifted = cq_out[8:0];

    logic [9:0] AC_stage1;
    mux2 #(10) ac_mux1 (.d0(AC_added), .d1(AC_shifted_part), .s(in_shift), .y(AC_stage1));
    mux2 #(10) ac_mux2 (.d0(AC_stage1), .d1(10'b0), .s(in_load), .y(AC_d));

    register #(.WIDTH(10)) AC_reg (
        .clk(clk), .rst_n(rst_n),
        .load_en(in_load | in_step | in_shift), .shift_en(1'b0), .sr(1'b0), .sl(1'b0), .shift_dir(1'b0),
        .d(AC_d), .q(AC_q)
    );

    //Final product, valid once done = 1
    assign Product = {AC_q[7:0], QR_q[8:1]};

endmodule // booth4_mult