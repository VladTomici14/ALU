//--------------------------------------------------------------------------
// Design Name: n-bit synchronous counter
// File Name: counter.sv
// Description: Implementation of a n-bit sync counter
// Version History
// * June 9, 2025 (sebastian ardelean): Finished the implementation 
// -------------------------------------------------------------------------

`timescale 1ns/1ps
module counter_nbits #(parameter WIDTH = 3)
   (
    input logic        clk,
    input logic        rst_n,
    input logic        en,
    output logic [WIDTH-1:0] count
    );

   logic [WIDTH-1:0] q;
   logic [WIDTH-1:0] and_gate_stages;
   
   jkff jk0 (
             .clk(clk),
             .rst_n(rst_n),
             .j(en),
             .k(en),
             .q(q[0]),
             .qn()
             );
   
   and2_gate a0 (
            .a(q[0]),
            .b(en),
            .y(and_gate_stages[0])
            );
            
            
   genvar i;
   generate
      for (i = 1; i < WIDTH; i++) begin: gen_ff
         if (i < WIDTH - 1) begin
            and2_gate a_i (
                      .a(q[i]),
                      .b(and_gate_stages[i-1]),
                      .y(and_gate_stages[i])
                      );
         end

         jkff jk_i (
                    .clk(clk),
                    .rst_n(rst_n),
                    .j(and_gate_stages[i-1]),
                    .k(and_gate_stages[i-1]),
                    .q(q[i]),
                    .qn()
                    );
      end // block: gen_ff
   endgenerate
   
   assign count = q;
  
endmodule // counter_nbits