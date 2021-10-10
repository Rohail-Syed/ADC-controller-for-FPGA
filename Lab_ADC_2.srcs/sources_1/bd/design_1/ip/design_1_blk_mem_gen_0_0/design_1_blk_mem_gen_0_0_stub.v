// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Fri Feb 19 01:42:54 2021
// Host        : AFT-PC running 64-bit unknown
// Command     : write_verilog -force -mode synth_stub
//               /tmp/.xilinx/Lab_ADC/Lab_ADC.srcs/sources_1/bd/design_1/ip/design_1_blk_mem_gen_0_0/design_1_blk_mem_gen_0_0_stub.v
// Design      : design_1_blk_mem_gen_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module design_1_blk_mem_gen_0_0(clka, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[13:0],dina[11:0],clkb,enb,addrb[13:0],doutb[11:0]" */;
  input clka;
  input [0:0]wea;
  input [13:0]addra;
  input [11:0]dina;
  input clkb;
  input enb;
  input [13:0]addrb;
  output [11:0]doutb;
endmodule
