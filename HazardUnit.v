module HazardDetectionUnit(PCSrc,ID_ExMemRead,EX_MemMemRead,ID_Ex_Rt,IF_ID_Instr,PCWrite,IF_IDWrite,IF_Flush,muxSelector);
  
  input ID_ExMemRead,EX_MemMemRead;
  input [1:0] PCSrc;
  input [4:0] ID_Ex_Rt;
  input [31:0] IF_ID_Instr;
  output reg PCWrite, IF_IDWrite,IF_Flush, muxSelector;
  parameter beqOPcode=6'b000100;
  parameter bneOPcode=6'b000101;

  initial
	begin
	PCWrite <= 1;
	IF_IDWrite <= 1;
	muxSelector <= 0;
	end

  always@(ID_ExMemRead or ID_Ex_Rt or IF_ID_Instr or PCSrc)
    begin
      if (ID_ExMemRead && PCWrite && IF_IDWrite)//lw hazard
        begin
          if(ID_Ex_Rt==IF_ID_Instr[25:21] || ID_Ex_Rt==IF_ID_Instr[20:16] )
            begin
              PCWrite<=0;
              IF_IDWrite<=0;
              muxSelector<=1;
            end
        end
      else if((IF_ID_Instr [31:26]==beqOPcode) && (IF_Flush==0))//beq hazard
        begin
          IF_Flush <= (PCSrc == 2'b01) ? 1 : 0;
        end

      else if((IF_ID_Instr [31:26]==bneOPcode) && (IF_Flush==0))//bne hazard
        begin
          IF_Flush <= (PCSrc == 2'b01) ? 1 : 0;
        end
        
                
      else
        begin
          PCWrite<=1;
          IF_IDWrite<=1;
          muxSelector<=0;
          IF_Flush<=0;    
        end    
      
    end
  
  
endmodule
