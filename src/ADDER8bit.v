`include "ADDER1bit.v"

module ADDER8bit(
  input wire [7:0] A,B,
  input wire Cin,
  output wire [7:0] S,
  output wire Cout
);
//  wire [8:0] Carry;
  wire c1, c2, c3, c4 ,c5, c6, c7;
  
//  assign Carry[0]=Cin;
//  assign Cout=Carry[8];
  
  ADDER1bit a0(
    .A (A[0]),
    .B (B[0]),
    .Cin (Cin),
//    .Cin (Carry[0]),
    .S (S[0]),
    .Cout (c1)
//    .Cout (Carry[1])
  );
  ADDER1bit a1(
    .A (A[1]),
    .B (B[1]),
//    .Cin (Carry[1]),
    .Cin (c1),
    .S (S[1]),
    .Cout (c2)
    //    .Cout (Carry[2])
  );
  ADDER1bit a2(
    .A (A[2]),
    .B (B[2]),
//    .Cin (Carry[2]),
    .Cin (c2),
    .S (S[2]),
    .Cout (c3)
    //    .Cout (Carry[3])
  );
  ADDER1bit a3(
    .A (A[3]),
    .B (B[3]),
//    .Cin (Carry[3]),
    .Cin (c3),
    .S (S[3]),
//    .Cout (Carry[4])
    .Cout (c4)
  );
  ADDER1bit a4(
    .A (A[4]),
    .B (B[4]),
//    .Cin (Carry[4]),
    .Cin (c4),
    .S (S[4]),
//    .Cout (Carry[5])
    .Cout (c5)
  );
  ADDER1bit a5(
    .A (A[5]),
    .B (B[5]),
//    .Cin (Carry[5]),
    .Cin (c5),
    .S (S[5]),
//    .Cout (Carry[6])
    .Cout (c6)
  );
  ADDER1bit a6(
    .A (A[6]),
    .B (B[6]),
//    .Cin (Carry[6]),
    .Cin (c6),
    .S (S[6]),
//    .Cout (Carry[7])
    .Cout (c7)
  );
  ADDER1bit a7(
    .A (A[7]),
    .B (B[7]),
//    .Cin (Carry[7]),
    .Cin (c7),
    .S (S[7]),
    .Cout (Cout)
//    .Cout (Carry[8])
  );
endmodule
