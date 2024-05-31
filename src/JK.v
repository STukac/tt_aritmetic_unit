module JK(
  input wire J, K, SET, RST, CLK,
  output wire Q, NQ
);
  reg Q0;
  always @ (posedge CLK, posedge ~RST)
    begin 
      if (~RST)
        Q0 <= 1'b0;
      else if(~SET)
        Q0 <= 1'b1;
      else
        case ({J,K})
          2'b00 : Q0 <= Q0;
          2'b01 : Q0 <= 1'b0;
          2'b10 : Q0 <= 1'b1;
          2'b11 : Q0 <= ~Q0;
        endcase
        
    end
  assign Q = Q0;
  assign NQ = ~Q0;
//  wire x0, x1;
//  assign x0 = ~(J & CLK & NQ);
//  assign x1 = ~(K & CLK & Q);
//  assign Q = ~(SET & x0 & NQ);
//  assign NQ = ~(RST & x1 & Q);
  
endmodule