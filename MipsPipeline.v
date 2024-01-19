`timescale 1ns/1ns
module Mux2_1_10b(input[9:0] Muxin1, Muxin2, input Sel, output[9:0] Muxout);
  assign Muxout = Sel ? Muxin2 : Muxin1;
endmodule

module MipsPipeline(input reset, clk);
  wire PCWrite, IF_IDWrite,ID_ExMemRead,EX_MemMemRead, IF_Flush, RegWrite, ALUSrc, RegDst, MemRead, MemWrite,MemToReg,zero,EX_MemRegwrite,Mem_WbRegwrite,muxSelector,eqFlag;
  wire[1:0] PCSrc, ForwardA, ForwardB,ALUop;
  wire[2:0] ALUOperation;
  wire[4:0] EX_MemWriteReg,Mem_WbWriteReg,ID_Ex_Rs,ID_Ex_Rt;
  wire[5:0] opcode, Function;
  wire[31:0] IF_ID_Instr;
  wire _RegDst,_MemRead,_MemToReg,_MemWrite,_ALUSrc,_RegWrite;
  wire [1:0] _PCSrc;
  wire [1:0] _ALUop;
  wire [9:0] SignalsToDP,ctrlSignals ;
  
  Datapath d(clk, reset, PCWrite, IF_IDWrite, IF_Flush, RegWrite, ALUSrc, RegDst, MemRead, MemWrite, MemToReg,PCSrc, ForwardA, ForwardB,ALUOperation,zero,EX_MemMemRead,ID_ExMemRead,Mem_WbRegwrite,EX_MemRegwrite,opcode, Function,EX_MemWriteReg,Mem_WbWriteReg,ID_Ex_Rs,ID_Ex_Rt,IF_ID_Instr,eqFlag);
  ControlUnit c(opcode,_RegDst,_MemRead,_MemToReg,_ALUop,_MemWrite,_ALUSrc,_RegWrite,_PCSrc, reset,eqFlag);
  ALUControl a(ALUop,Function,ALUOperation);
  ForwardingUnit f(EX_MemRegwrite,EX_MemWriteReg,Mem_WbRegwrite,Mem_WbWriteReg,ID_Ex_Rs,ID_Ex_Rt,ForwardA,ForwardB); 
  HazardDetectionUnit h(PCSrc,ID_ExMemRead,EX_MemMemRead,ID_Ex_Rt,IF_ID_Instr,PCWrite,IF_IDWrite,IF_Flush,muxSelector);
  assign ctrlSignals ={_RegDst,_MemRead,_MemToReg,_ALUop,_MemWrite,_ALUSrc,_RegWrite,_PCSrc};
  assign {RegDst,MemRead,MemToReg,ALUop,MemWrite,ALUSrc,RegWrite,PCSrc} = SignalsToDP;
  Mux2_1_10b m(ctrlSignals,10'b0000000000,muxSelector,SignalsToDP);
endmodule