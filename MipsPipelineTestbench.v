`timescale 1ns/1ns
module MipsPipelineTB();    
      reg clk;  
      reg reset;
      MipsPipeline uut(reset, clk);  
      initial begin  
           clk = 0;  
           forever #100 clk = ~clk;  
      end  
      initial begin 
      #50 
           reset = 1;  
           #150;
           reset = 0;
           #72000; 
           $stop;
      end  
 endmodule
