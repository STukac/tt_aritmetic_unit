`include "Reg4bit.v"

module Reg8bit(
  input wire [7:0] D,
  input wire RST, CLK,
  output wire [7:0] Q, NQ
);
  Reg4bit d0(
    .D (D[3:0]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[3:0]),
    .NQ (NQ[3:0])
  );
  Reg4bit d1(
    .D (D[7:4]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[7:4]),
    .NQ (NQ[7:4])
  );
  
endmodule