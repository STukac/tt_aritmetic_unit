`include "MUX32x16.v"

module MUX64x16(
  input wire [15:0] A, B, C, D,
  input wire a1, a0,
  output wire [15:0] O
);
  wire [15:0] x1, x0;
  MUX32x16 m2(
    .B (D),
    .A (C),
    .a0 (a0),
    .O (x1)
  );
  
  MUX32x16 m1(
    .B (B),
    .A (A),
    .a0 (a0),
    .O (x0)
  );
  
  MUX32x16 m0(
    .B (x1),
    .A (x0),
    .a0 (a1),
    .O (O)
  );
  
endmodule