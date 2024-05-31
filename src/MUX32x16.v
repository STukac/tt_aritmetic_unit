`include "MUX2x1.v"

module MUX32x16(
  input wire [15:0] A,B,
  input wire a0,
  output wire [15:0] O
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
  MUX2x1 m8(
    .I ({B[8], A[8]}),
    .a (a0),
    .o (O[8])
  );
  MUX2x1 m9(
    .I ({B[9], A[9]}),
    .a (a0),
    .o (O[9])
  );
  MUX2x1 m10(
    .I ({B[10], A[10]}),
    .a (a0),
    .o (O[10])
  );
  MUX2x1 m11(
    .I ({B[11], A[11]}),
    .a (a0),
    .o (O[11])
  );
  MUX2x1 m12(
    .I ({B[12], A[12]}),
    .a (a0),
    .o (O[12])
  );
  MUX2x1 m13(
    .I ({B[13], A[13]}),
    .a (a0),
    .o (O[13])
  );
  MUX2x1 m14(
    .I ({B[14], A[14]}),
    .a (a0),
    .o (O[14])
  );
  MUX2x1 m15(
    .I ({B[15], A[15]}),
    .a (a0),
    .o (O[15])
  );
  
endmodule