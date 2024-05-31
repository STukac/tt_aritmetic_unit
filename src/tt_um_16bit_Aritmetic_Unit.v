/*
 * Copyright (c) 2024 Sebastian Tukac
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`include "ADDER16bit.v"
`include "Change_Det.v"
`include "COUNTER8bit.v"
`include "F_edge.v"
`include "MUX8x1.v"
`include "MUX32x8.v"
`include "MUX64x16.v"
`include "R_edge.v"
`include "Reg2bit.v"
`include "Reg16bit.v"


module tt_um_16bit_Aritmetic_Unit (
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
    .CLK (clk),
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
    .CLK (clk),
    .Q (S_UIO_IN),
    .NQ (DUMMY0)
  );
  
//////////////////////////////////////////////////////////////
// SINC INPUT ui_in
  wire [7:0] S_UI_IN, DUMMY1;
  
  Reg8bit i_input(
    .D (ui_in),
    .RST (RST),
    .CLK (S),
    .Q (S_UI_IN),
    .NQ (DUMMY1)
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
// MUXOF BIT SELECTOR
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
   
  wire [15:0] DUMMY2;
  Reg16bit REG_A(
    .D (M0),
    .RST (RST),
    .CLK (RW & ~REG1 & LDR & S | CNT16 & clk & ~LDR),
    .Q (Reg_A),
    .NQ (DUMMY2)
    
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
  
  assign P = C & (ADD | SUB) & ( Reg_B[15] ^- M1[15] ^- SUM[15]) | ~C & ADD & Cout;
  assign N = C & SUM[15] | SUB & ~C & ~Cout;


////////////////////////////////////////////////////////////
// REG B'
  wire [15:0] Reg_B0, DUMMY3;
  Reg16bit REG_B0(
    .D (SUM),
    .RST (RST),
    .CLK (CNT14),
    .Q (Reg_B0),
    .NQ (DUMMY3)
    
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
  wire [15:0] DUMMY4;
  Reg16bit REG_B (
    .D (M2),
    .RST (RST),
    .CLK (RW & REG1 & LDR & S +CNT16 & r_e_clk & ~LDR),
    .Q (Reg_B),
    .NQ (DUMMY4)
  
  );
  
  
////////////////////////////////////////////////////////////
// REG OF READ
  wire [1:0] READ, DUMMY5;
  Reg2bit REG_R (
    .D ({REG1,REG0}),
    .RST (RST),
    .CLK (clk & ~RW),
    .Q (READ),
    .NQ (DUMMY5)
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





















/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Adders






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Counter









/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Registers















/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Edge detection







/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Change detection


  


    

