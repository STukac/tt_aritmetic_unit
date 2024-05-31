/*
 * Copyright (c) 2024 Sebastian Tukac
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  

// List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};
/////////////////////////////////////////////////////////////
// EDGE DETECTION
  wire r_e_clk, f_e_clk, RST, dummy0;
 
  R_edge r_clk (
    .I (clk),
    .RST (RST),
    .CLK (clk),
    .O (r_e_clk)
  );
  
  F_edge f_clk (
    .I (clk),
    .RST (RST),
    .CLK (clk),
    .O (f_e_clk)
  );
//////////////////////////////////////////////////////////////
// RESET
  D_Reg Reset (
    .D (~rst_n),
    .RST (1'b0),
    .CLK (r_e_clk),
    .Q (RST),
    .NQ (dummy0)
  );
  
//////////////////////////////////////////////////////////////
// DIRECTION OF BIDERECTIONAL PINS
  assign uio_oe = {1'b0 ,1'b0 ,1'b0 , uio_in[6] | uio_in[5], uio_in[6] | uio_in[5],uio_in[6] & uio_in[5],1'b0 ,1'b1};

//////////////////////////////////////////////////////////////
// SINC INPUT uio_in
  wire [7:0] S_UIO_IN, DUMMY0;
  
  Reg8bit r_input(
    .D (uio_in),
    .RST (RST),
    .CLK (r_e_clk),
    .Q (S_UIO_IN),
    .NQ (DUMMY0)
  );
  
//////////////////////////////////////////////////////////////
// SINC INPUT ui_in
  wire [7:0] S_UI_IN, DUMMY0;
  
  Reg8bit i_input(
    .D (ui_in),
    .RST (RST),
    .CLK (S),
    .Q (S_UI_IN),
    .NQ (DUMMY0)
  );

/////////////////////////////////////////////////////////////
// DETECT CHANGE IN COMPLEMENT -> SETS ERROR
  Change_Det C_Change (
    .I (S_UIO_IN[7]),
    .E (S_UIO_IN[1]),
    .RST (RST),
    .CLK (r_e_clk),
    .ERR (uio_out[0])
  );
  
  
/////////////////////////////////////////////////////////////
// UIO_IN
  wire C,LDR, ADD, SUB, MUL,S,ERR,P,N,F,UA,RW,REG1, REG0 ;
  
  assign C = S_UIO_IN[7];
  assign LDR = ~(S_UIO_IN[6] | S_UIO_IN[5]);
  assign ADD = ~S_UIO_IN[6] & S_UIO_IN[5];
  assign SUB = S_UIO_IN[6] & ~S_UIO_IN[5];
  assign MUL = S_UIO_IN[6] & S_UIO_IN[5];
  assign REG1 = S_UIO_IN[4];
  assign REG0 = S_UIO_IN[3];
  assign RW = S_UIO_IN[2];
  assign UA = S_UIO_IN[2];
  assign S=S_UIO_IN[1];
  assign ERR=S_UIO_IN[0];

//uio_out
  assign uio_out[7:1] = {S_UIO_IN[7:5],P,N,F,S_UIO_IN[1]};
  
////////////////////////////////////////////////////////////
// COUNTER 8bit
  wire [7:0] COUNT, CDUMMY;
  wire CNT16, CNT14, BF;
  assign CNT16 = COUNT[4];
  assign CNT14 = COUNT[3] & COUNT[2] & COUNT[1];
  assign BF = COUNT[6] & COUNT[5] & COUNT [4];
  assign F = COUNT[7];
  COUNTER8bit Counter(
    .RST (RST | ~S),
    .CLK (clk & CNT_EN),
    .Q (COUNT),
    .NQ (CDUMMY)
  );
  
  wire CNT_EN, dummyEN;
  
  D_Reg cnt_en (
    .D (S & ( MUL& ~F | (ADD | SUB) & ~CNT16)),
    .RST (RST),
    .CLK (clk),
    .Q (CNT_EN),
    .NQ (dummyEN)
  );
  
////////////////////////////////////////////////////////////
// MUX OF BIT SELECTOR
  wire MUL_MUX;
  MUX8x1 muxS(
    .I (S_UI_IN),
    .a (COUNT[6:4]),
    .o (MUL_MUX)
  );
  
////////////////////////////////////////////////////////////
// MUX OF REG A
  wire [15:0] Reg_A, M0;
  MUX64x16 mux0 (
    .D ({S_UI_IN, Reg_A [7:0]}),
    .C ({Reg_A [15:8],S_UI_IN}),
    .B ({Reg_A [14:0], 1'b0}),
    .A (Reg_A),
    .a1 (LDR),
    .a0 (LDR & REG0 | MUL),
    .O (M0)
    
  );

////////////////////////////////////////////////////////////
// REG A
   
  wire [15:0] DUMMY1;
  Reg16bit REG_A(
    .D (M0),
    .RST (RST),
    .CLK (RW & ~REG1 & LDR & S | CNT16 & clk & ~LDR),
    .Q (Reg_A),
    .NQ (DUMMY1)
    
  );
  
////////////////////////////////////////////////////////////
// MUX OF ADDER
    wire [15:0] M1;
  wire neg;
  assign neg = SUB | MUL & S_UI_IN[7] & C & BF; 
  MUX64x16 mux1 (
    .D (~Reg_A & {16{(MUL_MUX | ~ MUL)}}),
    .C (Reg_A & {16{(MUL_MUX | ~ MUL)}}),
    .B (~{{8{C & S_UI_IN[7]}},S_UI_IN}),
    .A ({{8{C & S_UI_IN[7]}},S_UI_IN}),
    .a1 (UA & (ADD | SUB) | MUL),
    .a0 (neg),
    .O (M1)
  
  ); 

////////////////////////////////////////////////////////////
// ADDER
  wire Cout;
  wire [15:0] Reg_B, SUM;
  ADDER16bit adder(
    .A (Reg_B),
    .B (M1),
    .Cin (neg),
    .S (SUM),
    .Cout (Cout)
  );
  
  assign P = Cout^(C & SUM[15]);
  assign N = SUM[15] & ( SUB | C& ( MUL | ADD));


////////////////////////////////////////////////////////////
// REG B'
  wire [15:0] Reg_B0, DUMMY2;
  Reg16bit REG_B0(
    .D (SUM),
    .RST (RST),
    .CLK (CNT14),
    .Q (Reg_B0),
    .NQ (DUMMY2)
    
  );


////////////////////////////////////////////////////////////
// MUX oF REG B
  wire [15:0] M2;
  MUX64x16 mux2 (
    .D ({S_UI_IN,Reg_B[7:0]}),
    .C ({Reg_B[15:8],S_UI_IN}),
    .B (Reg_B0),
    .A (Reg_B0),
    .a1 (LDR),
    .a0 (REG0 & LDR),
    .O (M2)
  );
  
////////////////////////////////////////////////////////////
// REG B
  wire [15:0] DUMMY3;
  Reg16bit REG_B (
    .D (M2),
    .RST (RST),
    .CLK (RW & REG1 & LDR & S +CNT16 & r_e_clk & ~LDR),
    .Q (Reg_B),
    .NQ (DUMMY3)
  
  );
  
  
////////////////////////////////////////////////////////////
// REG OF READ
  wire [1:0] READ, DUMMY4;
  Reg2bit REG_R (
    .D ({REG1,REG0}),
    .RST (RST),
    .CLK (clk & ~RW),
    .Q (READ),
    .NQ (DUMMY4)
  ); 
  


////////////////////////////////////////////////////////////
// MUX FOR OUTPUT
  MUX32x8 muxR(
    .D (Reg_B[15:8]),
    .C (Reg_B[7:0]),
    .B (Reg_A[15:8]),
    .A (Reg_A[7:0]),
    .a1 (READ[1]),
    .a0 (READ[0]),
    .O (uo_out)
  );
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Multiplexors

module MUX2x1(
  input wire [1:0] I, 
  input wire a,
  output wire o
);
  
  assign o = a & I[1] | ~a & I[0];
  
endmodule


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


module MUX32x8(
  input wire [7:0] A, B, C, D,
  input wire a1, a0,
  output wire [7:0] O
);
  wire [7:0] x1, x0;
  MUX16x8 m2(
    .B (D),
    .A (C),
    .a0 (a0),
    .O (x1)
  );
  
  MUX16x8 m1(
    .B (B),
    .A (A),
    .a0 (a0),
    .O (x0)
  );
  
  MUX16x8 m0(
    .B (x1),
    .A (x0),
    .a0 (a1),
    .O (O)
  );
  
endmodule


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


module MUX64x16(
  input wire [15:0] A, B, C, D,
  input wire a1, a0,
  output wire [15:0] O
);
  wire [15:0] x1, x0;
  MUX32x16 m2(
    .B (D),
    .A (C),
    .a0 (a0),
    .O (x1)
  );
  
  MUX32x16 m1(
    .B (B),
    .A (A),
    .a0 (a0),
    .O (x0)
  );
  
  MUX32x16 m0(
    .B (x1),
    .A (x0),
    .a0 (a1),
    .O (O)
  );
  
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Adders

module ADDER2bit (
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
  
  ADDER2bit a0(
    .A (A[0]),
    .B (B[0]),
    .Cin (Cin),
//    .Cin (Carry[0]),
    .S (S[0]),
    .Cout (c1)
//    .Cout (Carry[1])
  );
  ADDER2bit a1(
    .A (A[1]),
    .B (B[1]),
//    .Cin (Carry[1]),
    .Cin (c1),
    .S (S[1]),
    .Cout (c2)
    //    .Cout (Carry[2])
  );
  ADDER2bit a2(
    .A (A[2]),
    .B (B[2]),
//    .Cin (Carry[2]),
    .Cin (c2),
    .S (S[2]),
    .Cout (c3)
    //    .Cout (Carry[3])
  );
  ADDER2bit a3(
    .A (A[3]),
    .B (B[3]),
//    .Cin (Carry[3]),
    .Cin (c3),
    .S (S[3]),
//    .Cout (Carry[4])
    .Cout (c4)
  );
  ADDER2bit a4(
    .A (A[4]),
    .B (B[4]),
//    .Cin (Carry[4]),
    .Cin (c4),
    .S (S[4]),
//    .Cout (Carry[5])
    .Cout (c5)
  );
  ADDER2bit a5(
    .A (A[5]),
    .B (B[5]),
//    .Cin (Carry[5]),
    .Cin (c5),
    .S (S[5]),
//    .Cout (Carry[6])
    .Cout (c6)
  );
  ADDER2bit a6(
    .A (A[6]),
    .B (B[6]),
//    .Cin (Carry[6]),
    .Cin (c6),
    .S (S[6]),
//    .Cout (Carry[7])
    .Cout (c7)
  );
  ADDER2bit a7(
    .A (A[7]),
    .B (B[7]),
//    .Cin (Carry[7]),
    .Cin (c7),
    .S (S[7]),
    .Cout (Cout)
//    .Cout (Carry[8])
  );
endmodule


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


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Counter

module JK(
  input wire J, K, SET, RST, CLK,
  output wire Q, NQ
);
  reg Q0;
  always @ (posedge CLK)
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


module COUNTER4bit(
  input wire RST, CLK,
  output wire [3:0] Q, NQ
);
  wire Q0,Q1,Q2,Q3,NQ0,NQ1,NQ2,NQ3;
  JK jk0(
    .J (1'b1),
    .K (1'b1),
    .SET (1'b1),
    .RST (~RST),
    .CLK (CLK),
    .Q (Q0),
    .NQ (NQ0)
  );
  JK jk1(
    .J (1'b1),
    .K (1'b1),
    .SET (1'b1),
    .RST (~RST),
    .CLK (Q0),
    .Q (Q1),
    .NQ (NQ1)
  );
  JK jk2(
    .J (1'b1),
    .K (1'b1),
    .SET (1'b1),
    .RST (~RST),
    .CLK (Q1),
    .Q (Q2),
    .NQ (NQ2)
  );
  JK jk3(
    .J (1'b1),
    .K (1'b1),
    .SET (1'b1),
    .RST (~RST),
    .CLK (Q2),
    .Q (Q3),
    .NQ (NQ3)
  );
  assign Q = {Q3,Q2,Q1,Q0};
  assign NQ = {NQ3,NQ2,NQ1,NQ0};
endmodule

module COUNTER8bit(
  input wire RST, CLK,
  output wire [7:0] Q, NQ
);
  wire [3:0] Q1,Q0,NQ1,NQ0;
  wire q;
  COUNTER4bit c0(
    .RST (RST),
    .CLK (CLK),
    .Q (Q0),
    .NQ (NQ0)
  );
  assign q= Q0[3];
  COUNTER4bit c1(
    .RST (RST),
    .CLK (q),
    .Q (Q1),
    .NQ (NQ1)
  );
  assign Q = {Q1,Q0};
  assign NQ = {NQ1,NQ0};  
    
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Registers

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


module Reg2bit(
  input wire [1:0] D,
  input wire RST, CLK,
  output wire [1:0] Q, NQ
);
  D_Reg d0(
    .D (D[0]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[0]),
    .NQ (NQ[0])
  );
  D_Reg d1(
    .D (D[1]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[1]),
    .NQ (NQ[1])
  );
endmodule

module Reg4bit(
  input wire [3:0] D,
  input wire RST, CLK,
  output wire [3:0] Q, NQ
);
  D_Reg d0(
    .D (D[0]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[0]),
    .NQ (NQ[0])
  );
  D_Reg d1(
    .D (D[1]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[1]),
    .NQ (NQ[1])
  );
  D_Reg d2(
    .D (D[2]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[2]),
    .NQ (NQ[2])
  );
  D_Reg d3(
    .D (D[3]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[3]),
    .NQ (NQ[3])
  );
  
endmodule


module Reg8bit(
  input wire [7:0] D,
  input wire RST, CLK,
  output wire [7:0] Q, NQ
);
  Reg4bit d0(
    .D (D[3:0]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[3:0]),
    .NQ (NQ[3:0])
  );
  Reg4bit d1(
    .D (D[7:4]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[7:4]),
    .NQ (NQ[7:4])
  );
  
endmodule


module Reg16bit(
  input wire [15:0] D,
  input wire RST, CLK,
  output wire [15:0] Q, NQ
);
  Reg8bit d0(
    .D (D[7:0]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[7:0]),
    .NQ (NQ[7:0])
  );
  Reg8bit d1(
    .D (D[15:8]),
    .RST (RST),
    .CLK (CLK),
    .Q (Q[15:8]),
    .NQ (NQ[15:8])
  );
  
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Edge detection

module R_edge (
  input wire I, RST, CLK,
  output wire O
);
  wire NQ, dummy;
  D_Reg d(
    .D (I),
    .RST (RST),
    .CLK (CLK),
    .Q (dummy),
    .NQ (NQ)
  );
  assign O = NQ & I;
  
endmodule


module F_edge (
  input wire I, RST, CLK,
  output wire O
);
  wire Q, dummy;
  D_Reg d(
    .D (I),
    .RST (RST),
    .CLK (CLK),
    .Q (Q),
    .NQ (dummy)
  );
  assign O = Q & ~I;
  
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Change detection

module Change_Det (
  input wire I, E, RST, CLK,
  output wire ERR
);
  wire x2, x1,x0,dummy0, dummy1, dummy2;
  D_Reg delay(
    .D (~RST & ~RST),
    .CLK (CLK),
    .RST (RST),
    .Q (x0),
    .NQ (dummy0)
  );
  
  D_Reg last(
    .D (I & E),
    .CLK (CLK),
    .RST (RST),
    .Q (x1),
    .NQ (dummy1)
  );
  assign x2 = x1 ^- (I*E);
  
  JK Error(
    .J (x2 & x0),
    .K (1'b0),
    .SET (1'b0),
    .RST (RST),
    .CLK (x2 & x0),
    .Q (ERR),
    .NQ (dummy2)
  );
  
endmodule 
  


    

