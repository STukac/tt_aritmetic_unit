`include "D_Reg.v"

module R_edge (
  input wire I, RST, CLK,
  output wire O
);
  wire NQ, dummy;
  D_Reg d(
    .D (I),
    .RST (RST),
    .CLK (CLK),
    .Q (dummy),
    .NQ (NQ)
  );
  assign O = NQ & I;
  
endmodule