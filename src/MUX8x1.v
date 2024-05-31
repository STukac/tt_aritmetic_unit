`include "MUX4x1.v"

module MUX8x1(
  input wire [7:0] I,
  input wire [2:0] a,
  output wire o
);
  wire [1:0] o0;
  
  MUX4x1 m2(
    .I (I[7:4]),
    .a (a[1:0]),
    .o (o0[1])
  );
  
  MUX4x1 m1(
    .I (I[3:0]),
    .a (a[1:0]),
    .o (o0[0])
  );
  
  MUX2x1 m0(
    .I (o0),
    .a (a[2]),
    .o (o)
  );
  
endmodule