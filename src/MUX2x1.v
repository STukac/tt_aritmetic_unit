module MUX2x1(
  input wire [1:0] I, 
  input wire a,
  output wire o
);
  assign o = a & I[1] | ~a & I[0];
  
endmodule
