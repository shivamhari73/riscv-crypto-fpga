`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 16:15:08
// Design Name: 
// Module Name: control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control(
    input [6:0] instr,
    input zero,
    output reg ALUsrc, MemtoReg, Regwrite, Memread, Memwrite, Branch, 
    output reg [1:0] ALUop ,
    output PCsel
    
    );
    always@(*) begin
        case (instr) 
        7'b0110011: begin //R-type
                     ALUsrc = 1'b0; MemtoReg = 1'b0; Regwrite = 1'b1; Memread = 1'b0;
                     Memwrite = 1'b0; Branch = 1'b0 ; ALUop = 2'b10;
                    end
        7'b0100011: begin //sw
                     ALUsrc = 1'b1; MemtoReg = 1'bx; Regwrite = 1'b0; Memread = 1'b0;
                     Memwrite = 1'b1; Branch = 1'b0 ; ALUop = 2'b0;
                    end
        7'b0000011: begin //lw
                     ALUsrc = 1'b1; MemtoReg = 1'b1; Regwrite = 1'b1; Memread = 1'b1;
                     Memwrite = 1'b0; Branch = 1'b0 ; ALUop = 2'b0;
                    end 
        7'b1100011: begin //B-type
                     ALUsrc = 1'b0; MemtoReg = 1'bx; Regwrite = 1'b0; Memread = 1'b0;
                     Memwrite = 1'b0; Branch = 1'b1 ; ALUop = 2'b01;
                    end           
        7'b0010011: begin //I-type
                     ALUsrc = 1'b1; MemtoReg = 1'b0; Regwrite = 1'b1; Memread = 1'b0;
                     Memwrite = 1'b0; Branch = 1'b0 ; ALUop = 2'b11;
                    end    
        default: begin
                     ALUsrc = 1'b0; MemtoReg = 1'b0; Regwrite = 1'b0; Memread = 1'b0;
                     Memwrite = 1'b0; Branch = 1'b0 ; ALUop = 2'b00;
                    end        
        endcase
    end
    assign PCsel = Branch & zero ;
endmodule
