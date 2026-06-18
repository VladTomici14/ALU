//--------------------------------------------------------------------------
// Design Name: Radix-4 Booth Multiplier Control Unit
// File Name: cu_booth4.sv
// Description: 4-state control unit (IDLE, LOAD, STEP, SHIFT) driving the
//              radix-4 Booth multiplier datapath. One STEP+SHIFT pair per
//              2 bits of the multiplier; for an 8-bit operand that is
//              exactly 4 iterations, tracked externally by a 2-bit
//              counter whose "==3" condition is fed back in as
//              counter_is_3.
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module cu_booth4 (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic counter_is_3, // datapath: iteration counter has reached 3 (last step)

    output logic in_load,  // asserted during LOAD (latch M, QR, clear AC/counter)
    output logic in_step,  // asserted during STEP (accumulate one partial product)
    output logic in_shift, // asserted during SHIFT (shift AC:QR right by 2, advance counter)
    output logic done      // asserted while idle - Result is valid
);
    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        STEP,
        SHIFT
    } state_t;

    state_t state, next;

    always_ff @(posedge clk) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next;
    end

    always_comb begin
        next = state;
        in_load = 1'b0;
        in_step = 1'b0;
        in_shift = 1'b0;
        done = 1'b0;

        case (state)
            IDLE: begin
                done = 1'b1;
                if (start)
                    next = LOAD;
            end
            LOAD: begin
                in_load = 1'b1;
                next = STEP;
            end
            STEP: begin
                in_step = 1'b1;
                next = SHIFT;
            end
            SHIFT: begin
                in_shift = 1'b1;
                if (counter_is_3)
                    next = IDLE;
                else
                    next = STEP;
            end
        endcase
    end

endmodule // cu_booth4