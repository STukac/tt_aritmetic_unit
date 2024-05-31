`include "Reg8bit.v"

module Reg16bit(
  input wire [15:0] D,
  input wire RST, CLK,
  output wire [15:0] Q, NQ
);
  Reg8bit d0(
    .D (D[7:0]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[7:0]),
    .NQ (NQ[7:0])
  );
  Reg8bit d1(
    .D (D[15:8]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[15:8]),
    .NQ (NQ[15:8])
  );
  
endmodule