`include "JK.v"

module COUNTER4bit(
  input wire RST, CLK,
  output wire [3:0] Q, NQ
);
  wire Q0,Q1,Q2,Q3,NQ0,NQ1,NQ2,NQ3;
  JK jk0(
    .J (1'b1),
    .K (1'b1),
    .SET (1'b1),
    .RST (~RST),
    .CLK (~CLK),
    .Q (Q0),
    .NQ (NQ0)
  );
  JK jk1(
    .J (1'b1),
    .K (1'b1),
    .SET (1'b1),
    .RST (~RST),
    .CLK (~Q0),
    .Q (Q1),
    .NQ (NQ1)
  );
  JK jk2(
    .J (1'b1),
    .K (1'b1),
    .SET (1'b1),
    .RST (~RST),
    .CLK (~Q1),
    .Q (Q2),
    .NQ (NQ2)
  );
  JK jk3(
    .J (1'b1),
    .K (1'b1),
    .SET (1'b1),
    .RST (~RST),
    .CLK (~Q2),
    .Q (Q3),
    .NQ (NQ3)
  );
  assign Q = {Q3,Q2,Q1,Q0};
  assign NQ = {NQ3,NQ2,NQ1,NQ0};
endmodule