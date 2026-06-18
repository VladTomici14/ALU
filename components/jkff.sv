//--------------------------------------------------------------------------
// Design Name: JK Flip Flop
// File Name: jkff.sv
// Description: Implementation of the JK Flip FLop
// Version History
// June 9, 2025 (sebastian ardelean): Finished the implementation
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module jkff (
             input logic clk,
             input logic rst_n,
             input logic j,
             input logic k,
             output logic q,
             output logic qn
             );
   always_ff @(posedge clk) begin
      if (!rst_n)
        q <= 1'b0;
      else begin
         case ({j,k})
           2'b00: q <= q;    // no change
           2'b01: q <= 1'b0; // reset
           2'b10: q <= 1'b1; // set
           2'b11: q <= ~q;   // Toggle
         endcase // case ({j,k})
      end
   end // always_ff @ (posedge clk)
   assign qn =~q;
endmodule // jkf