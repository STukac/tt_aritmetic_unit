`include "ADDER8bit.v"

module ADDER16bit(
  input wire [15:0] A,B,
  input wire Cin,
  output wire [15:0] S,
  output wire Cout
);
  wire C;
  
  ADDER8bit a0(
    .A (A[7:0]),
    .B (B[7:0]),
    .Cin (Cin),
    .S (S[7:0]),
    .Cout (C)
  );
  ADDER8bit a1(
    .A (A[15:8]),
    .B (B[15:8]),
    .Cin (C),
    .S (S[15:8]),
    .Cout (Cout)
  );
  
endmodule