module ControlUnit (opcode,RegDst,MemRead,MemToReg,ALUop,MemWrite,AluSrc,RegWrite,PCsrc, reset,zero);
  
  input [5:0] opcode;
  input reset,zero;
  output reg RegDst,MemRead,MemToReg,MemWrite,AluSrc,RegWrite;
  output reg [1:0] PCsrc;
  output reg [1:0] ALUop;
  reg [1:0] branch;
  
  
  parameter R_type=6'b000000;
  parameter lw=6'b100011;
  parameter sw=6'b101011;
  parameter beq=6'b000100;
  parameter bne=6'b000101;
  parameter addi = 6'b001000; 
  parameter andi = 6'b001100; 
  parameter j = 6'b000010;

  always @(posedge reset)
  begin
   RegDst <= 1'b0;
   branch <= 2'b00;
   MemRead <= 1'b0;
   MemToReg <= 1'b0;
   ALUop <= 2'b00;
   MemWrite <= 1'b0;
   AluSrc <= 1'b0;
   RegWrite <= 1'b0;
   PCsrc <= 2'b0;
  end

  always@(opcode, zero)
    begin
      case (opcode)

        R_type:           

          begin
          RegDst<=1 ;
          branch<=2'b00 ;
          MemRead<=0 ;
          MemToReg<=0 ;
          MemWrite<=0 ;
          AluSrc<=0 ;
          RegWrite<=1 ;
          ALUop<=2'b10 ;
          PCsrc<=2'b00;
          end
          
          
        
        lw:           

          begin
          RegDst<=0 ;
          branch<=2'b00 ;
          MemRead<=1 ;
          MemToReg<=1 ;
          MemWrite<=0 ;
          AluSrc<=1 ;
          RegWrite<=1 ;
          ALUop<=2'b00 ;
          PCsrc<=2'b00;
          end
         
        
        sw:           

          begin
          //RegDst<=1'bx ;
          branch<= 2'b00 ;
          MemRead<=0 ;
          MemToReg<=0 ;
          MemWrite<=1 ;
          AluSrc<=1 ;
          RegWrite<=0 ;
          ALUop<=2'b00 ;
          PCsrc<=2'b00;
          end
          
        beq:           

          begin
          //RegDst<=1'bx ;
          branch<= 2'b01;
          MemRead<=0 ;
          MemToReg<=0 ;
          MemWrite<=0 ;
          AluSrc<=0 ;
          RegWrite<=0 ;
          ALUop<=2'b01 ;
          PCsrc <= (zero ? 2'b01 : 2'b00); 
          end
          
        bne:           

          begin
          //RegDst<=1'bx ;
          branch<= 2'b10;
          MemRead<=0 ;
          MemToReg<=0 ;
          MemWrite<=0 ;
          AluSrc<=0 ;
          RegWrite<=0 ;
          ALUop<=2'b01 ;
          PCsrc <= ((~zero) ? 2'b01:2'b00);
          end

	      addi:           

          begin
          RegDst<=0 ;
          branch<=2'b00 ;
          MemRead<=0 ;
          MemToReg<=0 ;
          MemWrite<=0 ;
          AluSrc<=1 ;
          RegWrite<=1 ;
          ALUop<=2'b00 ;
          PCsrc<=2'b00;
          end

	      andi:           

          begin
          RegDst<=0 ;
          branch<=2'b00 ;
          MemRead<=0 ;
          MemToReg<=0 ;
          MemWrite<=0 ;
          AluSrc<=1 ;
          RegWrite<=1 ;
          ALUop<=2'b11 ;
          PCsrc<=2'b00;
          end
          
        j:           

          begin
          branch<=2'b00 ;
          MemRead<=0 ;
          MemWrite<=0 ;
          RegWrite<=0 ;
          PCsrc <= 2'b10;
          end
          
      endcase
    end
endmodule