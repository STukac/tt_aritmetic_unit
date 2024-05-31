`include "D_Reg.v"

module Reg2bit(
  input wire [1:0] D,
  input wire RST, CLK,
  output wire [1:0] Q, NQ
);
  D_Reg d0(
    .D (D[0]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[0]),
    .NQ (NQ[0])
  );
  D_Reg d1(
    .D (D[1]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[1]),
    .NQ (NQ[1])
  );
endmodule