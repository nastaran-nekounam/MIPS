module ForwardingUnit (EX_MemRegwrite,EX_MemWriteReg,Mem_WbRegwrite,Mem_WbWriteReg,ID_Ex_Rs,ID_Ex_Rt,ForwardA,ForwardB);
  
  input EX_MemRegwrite, Mem_WbRegwrite;
  input [4:0] EX_MemWriteReg , Mem_WbWriteReg, ID_Ex_Rs, ID_Ex_Rt;
  output reg [1:0] ForwardA, ForwardB;
  
  always@(EX_MemRegwrite or EX_MemWriteReg or Mem_WbRegwrite or Mem_WbWriteReg or ID_Ex_Rs or ID_Ex_Rt)
    
    begin
      ForwardA<=2'b00;
      ForwardB<=2'b00;
      if(EX_MemRegwrite && EX_MemWriteReg)  //1,2
        begin
          if (EX_MemWriteReg==ID_Ex_Rs)
            ForwardA<=2'b10;
          else 
            ForwardA<=2'b00;
            
          if(EX_MemWriteReg==ID_Ex_Rt)
            ForwardB<=2'b10;
          else 
          ForwardB<=2'b00;
            
        end
        
        
        
      
      if (Mem_WbRegwrite && Mem_WbWriteReg)   //1,3
        begin
          if ((Mem_WbWriteReg==ID_Ex_Rs) && (~((EX_MemWriteReg==ID_Ex_Rs) &&EX_MemRegwrite && EX_MemWriteReg)))
            begin
            ForwardA<=2'b01;
            end
          else 
          begin
          ForwardA<=2'b00;
          end
            

            
          if((Mem_WbWriteReg==ID_Ex_Rt) && (~((EX_MemWriteReg==ID_Ex_Rt) &&EX_MemRegwrite && EX_MemWriteReg )))
          begin
            ForwardB<=2'b01;
          end

          else 
          begin
          ForwardB<=2'b00;
          end

          
        end
      

        
      
      
    end
  
endmodule