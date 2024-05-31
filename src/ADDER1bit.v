module ADDER1bit (
  input wire A, B, Cin,
  output wire S, Cout
);
  wire x1,x2,x3;
  
  assign x1 = A^B;
  assign S = x1^Cin;
  assign x2 = x1 & Cin;
  assign x3 = A & B;
  assign Cout = x2 | x3;
  
endmodule