`include "MUX2x1.v"

module MUX16x8(
  input wire [7:0] A,B,
  input wire a0,
  output wire [7:0] O
);
   MUX2x1 m0(
    .I ({B[0], A[0]}),
    .a (a0),
    .o (O[0])
  );
  MUX2x1 m1(
    .I ({B[1], A[1]}),
    .a (a0),
    .o (O[1])
  );
  MUX2x1 m2(
    .I ({B[2], A[2]}),
    .a (a0),
    .o (O[2])
  );
  MUX2x1 m3(
    .I ({B[3], A[3]}),
    .a (a0),
    .o (O[3])
  );
  MUX2x1 m4(
    .I ({B[4], A[4]}),
    .a (a0),
    .o (O[4])
  );
  MUX2x1 m5(
    .I ({B[5], A[5]}),
    .a (a0),
    .o (O[5])
  );
  MUX2x1 m6(
    .I ({B[6], A[6]}),
    .a (a0),
    .o (O[6])
  );
  MUX2x1 m7(
    .I ({B[7], A[7]}),
    .a (a0),
    .o (O[7])
  );
endmodule