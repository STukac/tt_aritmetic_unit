`include "D_Reg.v"

module F_edge (
  input wire I, RST, CLK,
  output wire O
);
  wire Q, dummy;
  D_Reg d(
    .D (I),
    .RST (RST),
    .CLK (CLK),
    .Q (Q),
    .NQ (dummy)
  );
  assign O = Q & ~I;
  
endmodule