`timescale 1ns/1ns
module PC(input[31:0] PCin, input clk, reset, PCWrite, output reg[31:0] PCout);
  always @(posedge clk) begin
    if (reset)
      PCout <= 32'b0;
    else if (PCWrite)
      PCout <= PCin;
    $display("pc%d -> %d", PCin, PCout);
  end
endmodule

module InstMem(input[31:0] addr, input clk, output[31:0] Inst);
  reg[31:0] instMem[0:63999];
  initial begin
    $readmemh("Inst1.data", instMem);
  end
  assign Inst = instMem[addr[31:2]];
endmodule

module ALU(input[31:0] A, B, input[2:0] ALUOperation, output reg[31:0] ALURes, output zero);
  assign zero = (ALURes == 0);
  always @(*) begin
  case (ALUOperation)
    0: ALURes <= A & B;
    1: ALURes <= A | B;
    2: ALURes <= A + B;
    3: ALURes <= A - B;
    7: ALURes <= (A < B) ? 1:0;
    default: ALURes <= 0;
  endcase
end
endmodule

module Adder(input[31:0] Add1, Add2, output[31:0] AddRes);
  assign AddRes = Add1 + Add2;
endmodule

module RegFile(input[4:0] ReadReg1, ReadReg2, WriteReg, input[31:0] WriteData, input clk, RegWrite, 
output reg[31:0] ReadData1, ReadData2);
  reg[31:0] regMem[0:31];
  initial begin
    regMem[0] = 0;
  end
  always @(*) begin
    ReadData1 = regMem[ReadReg1];
    ReadData2 = regMem[ReadReg2];
  end
  always @(negedge clk)  begin
    if (RegWrite)
      regMem[WriteReg] <= WriteData;
    end
    always@(*) begin
    $display("R1%d", regMem[1]);
    $display("R2%d", regMem[2]);
    $display("R3%d", regMem[3]);
    $display("R4%d", regMem[4]);
    $display("R10%d", regMem[10]);
    $display("R11%d", regMem[11]);
    $display("R12%d", regMem[12]);
  end
endmodule

module DataMem(input[31:0] Addr, WriteData, input clk, MemRead, MemWrite, output[31:0] ReadData);
  reg[31:0] Mem[0:63999];
  initial begin
    $readmemh("MemData.data", Mem, 250, 269);
  end
  assign ReadData = Mem[Addr[31:2]];
  always @(posedge clk) begin
    if (MemWrite)
      Mem[Addr[31:2]] <= WriteData;
    end
  always@(*) begin
    $display("Mem2000%d", Mem[500]);
    $display("Mem2004%d", Mem[501]);
  end
endmodule

module SignExtend(input[15:0] SEin, output[31:0] SEout);
  assign SEout = {{16{SEin[15]}}, SEin[15:0]};
endmodule

module Shl2(input[31:0] Shin, output[31:0] Shout);
  assign Shout = {Shin[29:0], 2'b00};
endmodule

module Mux5bit(input[4:0] Muxin1, Muxin2, input Sel, output[4:0] Muxout);
  assign Muxout = Sel ? Muxin2 : Muxin1;
endmodule

module Mux2To1(input[31:0] Muxin1, Muxin2, input Sel, output[31:0] Muxout);
  assign Muxout = Sel ? Muxin2 : Muxin1;
endmodule

module Mux3To1(input[31:0] Muxin1, Muxin2, Muxin3, input[1:0] Sel, output[31:0] Muxout);
    assign Muxout = (Sel == 2'b00) ? Muxin1 : ((Sel == 2'b01) ? Muxin2 : (Sel == 2'b10) ? Muxin3: 32'bx);
endmodule

module Comparator(input[31:0] in1, in2, output eqFlag);
  assign eqFlag = (in1 == in2) ? 1'b1 : 1'b0;
endmodule

module IFToIDReg(input[31:0] PCplus4, inst, input IFToIDWrite, IF_Flush, clk, output reg[31:0] PCplus4Out, instOut);
  always @(posedge clk) begin
    if (IFToIDWrite) begin
      instOut <= inst;
      PCplus4Out <= PCplus4;
    end
    if (IF_Flush)
      instOut <= 32'b0;
  end
endmodule

module IDToEXReg(input[2:0] ALUOp, input RegDst, RegWrite, ALUSrc, MemRead, MemWrite, MemToReg, input[31:0] ReadData1, 
ReadData2, addr, input[4:0] Rt, Rd, Rs, input clk, output reg[2:0] IDToEXALUOp, output reg IDToEXRegDst, IDToEXRegWrite, 
IDToEXALUSrc, IDToEXMemRead, IDToEXMemWrite, IDToEXMemToReg, output reg[31:0] IDToEXReadData1, IDToEXReadData2, IDToEXaddr, 
output reg[4:0] IDToEXRt, IDToEXRd, IDToEXRs);
  always @(posedge clk) begin
    IDToEXALUOp <= ALUOp;
    IDToEXRegDst <= RegDst; 
    IDToEXRegWrite <= RegWrite; 
    IDToEXALUSrc <= ALUSrc; 
    IDToEXMemRead <= MemRead;
    IDToEXMemWrite <= MemWrite; 
    IDToEXMemToReg <= MemToReg;
    IDToEXReadData1 <= ReadData1; 
    IDToEXReadData2 <= ReadData2; 
    IDToEXaddr <= addr;
    IDToEXRt <= Rt;
    IDToEXRd <= Rd;
    IDToEXRs <= Rs;
  end
endmodule

module EXToMEMReg(input RegWrite, MemRead, MemWrite, MemToReg, Zero, input[31:0] ALURes, ForwardingUnitBMux, 
input[4:0] RegDstMux, input clk, output reg EXToMEMRegWrite, EXToMEMMemRead, EXToMEMMemWrite, EXToMEMMemToReg, EXToMEMZero, 
output reg[31:0] EXToMEMALURes, EXToMEMForwardingUnitBMux, output reg[4:0] EXToMEMRegDstMux);
  always @(posedge clk) begin
    EXToMEMRegWrite <= RegWrite;
    EXToMEMMemRead <= MemRead; 
    EXToMEMMemWrite <= MemWrite; 
    EXToMEMMemToReg <= MemToReg; 
    EXToMEMZero <= Zero;
    EXToMEMALURes <= ALURes;
    EXToMEMForwardingUnitBMux <= ForwardingUnitBMux;
    EXToMEMRegDstMux <= RegDstMux;
  end
endmodule

module MEMToWBReg(input RegWrite, MemToReg, input[31:0] ReadData, Addr, input[4:0] WriteReg, input clk, 
output reg MEMToWBRegWrite, MEMToWBMemToReg, output reg[31:0] MEMToWBReadData, MEMToWBAddr, output reg[4:0] MEMToWBWriteReg);
  always @(posedge clk) begin
    MEMToWBRegWrite <= RegWrite; 
    MEMToWBMemToReg <= MemToReg; 
    MEMToWBReadData <= ReadData; 
    MEMToWBAddr <= Addr;
    MEMToWBWriteReg <= WriteReg;
  end
endmodule
  
module Datapath(input clk, reset, PCWrite, IFToIDWrite, IF_Flush, RegWrite, ALUSrc, RegDst, MemRead, MemWrite, 
MemtoReg, input[1:0] PCSrc, ForwardingUnitA, ForwardingUnitB, input[2:0] ALUOperation, output zero,EXToMEMMemRead,IDToEXMemRead, MEMToWBRegWrite,EXToMEMRegWrite, 
output[5:0] opcode, Function, output[4:0] EXToMEMRd,MemToWBRd, IDToEXRs, IDToEXRt, output [31:0] instOut , output eqFlag);
  wire IDToEXRegDst, IDToEXRegWrite, IDToEXALUSrc, IDToEXMemWrite, 
  IDToEXMemtoReg, EXToMEMMemWrite, EXToMEMMemtoReg, EXToMEMZero, MEMToWBMemtoReg;
  wire[2:0] IDToEXALUOp;
  wire[31:0] PCin, PCout, add1in, add1Res, inst, mux1in1, mux1in2, mux1in3, mux1out, PCplus4Out, Sh1in, 
  Sh1out, add2in1, add2in2, add2Res, mux6out, ReadData1, ReadData2, SEout, IDToEXReadData1, IDToEXReadData2, IDToEXaddr, 
  EXToMEMAddr, mux4out, A, B, ALURes, mux3out, mux2out, EXToMEMRes, EXToMEMmux3out, 
  ReadData, MEMToWBReadData, MEMToWBAddr, IDToEXSEout;
  wire[4:0] ReadReg1, ReadReg2, WriteReg, Rt, Rd, Rs, IDToEXRd, mux5out, EXToMEMmux5out,MEMToWBmux5out;
  wire[15:0] SEin;
  reg flag;
  PC pc(PCin, clk, reset, PCWrite, PCout);
  Adder adder1(32'b0100, add1in, add1Res);
  InstMem instMem(PCout, clk, inst);
  Mux3To1 mux1(mux1in1, mux1in2, mux1in3, (flag ? 2'b00 : PCSrc), mux1out);
  IFToIDReg IFToID(add1Res, inst, IFToIDWrite, IF_Flush, clk, PCplus4Out, instOut);
  Shl2 shl2first(Sh1in, Sh1out);
  Adder adder2(add2in1, add2in2, add2Res);
  RegFile regFile(ReadReg1, ReadReg2, MEMToWBmux5out, mux6out, clk, MEMToWBRegWrite, ReadData1, ReadData2);
  Comparator comparator(ReadData1, ReadData2, eqFlag);
  SignExtend signExtend(SEin, SEout);
  IDToEXReg IDToEX(ALUOperation, RegDst, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, ReadData1, ReadData2, SEout, Rt, Rd, 
  Rs, clk, IDToEXALUOp, IDToEXRegDst, IDToEXRegWrite, IDToEXALUSrc, IDToEXMemRead, IDToEXMemWrite, IDToEXMemtoReg, 
  IDToEXReadData1, IDToEXReadData2, IDToEXSEout, IDToEXRt, IDToEXRd, IDToEXRs);
  Mux3To1 mux2(IDToEXReadData1, mux6out, EXToMEMAddr, ForwardingUnitA, mux2out);
  Mux3To1 mux3(IDToEXReadData2, mux6out, EXToMEMAddr, ForwardingUnitB, mux3out);
  Mux2To1 mux4(mux3out, IDToEXSEout, IDToEXALUSrc, mux4out);
  Mux5bit mux5(IDToEXRt, IDToEXRd, IDToEXRegDst, mux5out);
  ALU alu(A, B, IDToEXALUOp, ALURes, zero);
  EXToMEMReg EXToMEM(IDToEXRegWrite, IDToEXMemRead, IDToEXMemWrite, IDToEXMemtoReg, zero, ALURes, mux3out, mux5out, clk, 
  EXToMEMRegWrite, EXToMEMMemRead, EXToMEMMemWrite, EXToMEMMemtoReg, EXToMEMZero, EXToMEMRes, EXToMEMmux3out, EXToMEMmux5out);
  DataMem dataMem(EXToMEMRes, EXToMEMmux3out, clk, EXToMEMMemRead, EXToMEMMemWrite, ReadData);
  MEMToWBReg MEMToWB(EXToMEMRegWrite, EXToMEMMemtoReg, ReadData, EXToMEMRes, EXToMEMmux5out, clk, MEMToWBRegWrite, 
  MEMToWBMemtoReg, MEMToWBReadData, MEMToWBAddr, MEMToWBmux5out);
  Mux2To1 mux6(MEMToWBAddr,MEMToWBReadData, MEMToWBMemtoReg, mux6out);
  assign A = mux2out;
  assign B = mux4out;
  assign Rs = instOut[25:21];
  assign Rt = instOut[20:16];
  assign Rd = instOut[15:11];
  assign ReadReg1 = instOut[25:21];
  assign ReadReg2 = instOut[20:16];
  assign mux1in1 = add1Res;
  assign mux1in2 = add2Res;
  assign mux1in3 = {add1Res[31:28], instOut[25:0], 2'b00};
  assign PCin = mux1out;
  assign add2in1 = PCplus4Out;
  assign add2in2 = Sh1out;
  assign SEin = instOut[15:0];
  assign Sh1in = SEout;
  assign opcode = instOut[31:26];
  assign Function = instOut[5:0];
  
  assign EXToMEMRd= EXToMEMmux5out;
  assign MemToWBRd = MEMToWBmux5out;
  assign add1in = PCout;
  always @(posedge clk) begin
    flag <= reset;
  end
endmodule