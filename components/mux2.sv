//--------------------------------------------------------------------------
// Design Name: Multiplexer
// File Name: mux.sv
// Description: Implementation of the multiplexer
// Version History
// * June 9, 2025 (sebastian ardelean): Finished the implementation 
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule //mux2