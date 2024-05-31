module D_Reg(
  input wire D, RST, CLK,
  output wire Q, NQ
);
  reg Q0;
  always @ (posedge CLK)
    begin 
      if (RST)
        Q0 <= 1'b0;
      else
        Q0 <= D;
    end
  assign Q = Q0;
  assign NQ = ~Q0;
 
  
//  wire x0, x1;
  
//  assign x0 = ~(D & ~RST & CLK);
//  assign x1 = ~(x0 & CLK);
  
// assign Q = ~(NQ & x1);
//  assign NQ = ~(Q & x0);
    
endmodule