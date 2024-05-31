`include "D_Reg.v"

module Reg4bit(
  input wire [3:0] D,
  input wire RST, CLK,
  output wire [3:0] Q, NQ
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
  D_Reg d2(
    .D (D[2]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[2]),
    .NQ (NQ[2])
  );
  D_Reg d3(
    .D (D[3]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[3]),
    .NQ (NQ[3])
  );
  
endmodule