//--------------------------------------------------------------------------
// Design Name: D-type flip-flop
// File Name: dff.sv
// Description: Implementation of the D-type flip-flop
// Version History
// June 9, 2025 (sebastian ardelean): Finished the implementation
// June 27, 2025 (Sebastian Ardelean): Changed to synchronous reset!
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module dff (
	    input logic		     clk,
	    input logic		     rst_n,
	    input logic d,
	    output logic q
    );

   always_ff @(posedge clk) begin
      if (!rst_n)
	q <= 1'b0;
      else
	q <= d;
   end
endmodule //dff