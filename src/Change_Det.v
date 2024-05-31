`include "D_Reg.v"
`include "JK.v"

module Change_Det (
  input wire I, E, RST, CLK,
  output wire ERR
);
  wire x2, x1,x0,dummy0, dummy1, dummy2;
  D_Reg delay(
    .D (~RST & ~RST),
    .CLK (CLK),
    .RST (RST),
    .Q (x0),
    .NQ (dummy0)
  );
  
  D_Reg last(
    .D (I),
    .CLK (CLK),
    .RST (RST),
    .Q (x1),
    .NQ (dummy1)
  );
  assign x2 = x1 ^- (I & E);
  
  JK Error(
    .J (x2 & x0),
    .K (1'b0),
    .SET (1'b0),
    .RST (~RST),
    .CLK (x2 & x0),
    .Q (ERR),
    .NQ (dummy2)
  );
  
endmodule 