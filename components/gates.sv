//--------------------------------------------------------------------------
// Design Name: Logic Gates
// File Name: gates.sv
// Description: Implementation of the used logic gates.
// Version History
// * June 9, 2025 (sebastian ardelean): Finished the implementation
// * <today> : Added xor2_gate (basic 2-input XOR), needed by full_adder.
// -------------------------------------------------------------------------
`timescale 1ns/1ps
module and3_gate ( input logic  a,
	      input logic  b,
	      input logic  c,
	      output logic y
	     );
   assign y = (a & b & c);
endmodule // and_gate

module and2_gate (input logic a,
             input logic b,
             output logic y
             );
   assign y = (a & b);
endmodule // and2_gate

module or2_gate (input logic a,
             input logic b,
             output logic y
             );
   assign y = (a | b);

endmodule // or2_gate

module xor2_gate (input logic a,
             input logic b,
             output logic y
             );
   assign y = (a ^ b);

endmodule // xor2_gate

module xorn_gate #(parameter WIDTH=8)
   (input logic [WIDTH-1:0]  a,
    input logic	      b,
    output logic [WIDTH-1:0] y);

   assign y = a ^ {WIDTH{b}};

endmodule // xorn_gate