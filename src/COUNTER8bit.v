`include "COUNTER4bit.v"

module COUNTER8bit(
  input wire RST, CLK,
  output wire [7:0] Q, NQ
);
  wire [3:0] Q1,Q0,NQ1,NQ0;
  wire q;
  COUNTER4bit c0(
    .RST (RST),
    .CLK (CLK),
    .Q (Q0),
    .NQ (NQ0)
  );
  assign q= Q0[3];
  COUNTER4bit c1(
    .RST (RST),
    .CLK (q),
    .Q (Q1),
    .NQ (NQ1)
  );
  assign Q = {Q1,Q0};
  assign NQ = {NQ1,NQ0};  
    
endmodule