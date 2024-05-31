`include "MUX16x8.v"

module MUX32x8(
  input wire [7:0] A, B, C, D,
  input wire a1, a0,
  output wire [7:0] O
);
  wire [7:0] x1, x0;
  MUX16x8 m2(
    .B (D),
    .A (C),
    .a0 (a0),
    .O (x1)
  );
  
  MUX16x8 m1(
    .B (B),
    .A (A),
    .a0 (a0),
    .O (x0)
  );
  
  MUX16x8 m0(
    .B (x1),
    .A (x0),
    .a0 (a1),
    .O (O)
  );
  
endmodule