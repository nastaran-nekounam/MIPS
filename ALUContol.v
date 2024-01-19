module ALUControl(input [1:0] ALUop, input [5:0] Function, output reg[2:0] ALUOperation);    
        wire [7:0] ALUControlIn;  
        assign ALUControlIn = {ALUop,Function};  
        always @(ALUControlIn)  
        casex (ALUControlIn)  
                8'b11xxxxxx: ALUOperation=3'b000;  
                8'b00xxxxxx: ALUOperation=3'b010;  
                8'b01xxxxxx: ALUOperation=3'b011;  
                8'b10100001: ALUOperation=3'b000;  
                8'b10100101: ALUOperation=3'b001;  
                8'b10100000: ALUOperation=3'b010;  
                8'b10100010: ALUOperation=3'b011;  
                8'b10101010: ALUOperation=3'b111;  
                default: ALUOperation=3'b000;  
        endcase  
endmodule
