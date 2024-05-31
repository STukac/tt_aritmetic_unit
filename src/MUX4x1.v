`include "MUX2x1.v"

module MUX4x1(
  input wire [3:0] I,
  input wire [1:0] a,
  output wire o
);
  wire [1:0] o0;
  
  MUX2x1 m2(
    .I (I[3:2]),
    .a (a[0]),
    .o (o0[1])
  );
  
  MUX2x1 m1(
    .I (I[1:0]),
    .a (a[0]),
    .o (o0[0])
  );
  
  MUX2x1 m0(
    .I (o0),
    .a (a[1]),
    .o (o)
  );
  
endmodule
