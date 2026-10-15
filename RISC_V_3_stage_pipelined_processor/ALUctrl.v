`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 23:00:34
// Design Name: 
// Module Name: ALUctrl
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


module ALUctrl(
    input [1:0]ALUOp,
    input funct7,
    input [2:0] funct3,
    output reg [3:0]ALUctrl

    );
    
    always@(*) begin
        case(ALUOp)
        2'b00: ALUctrl = 4'b0000;
        2'b01: ALUctrl = 4'b1000;
           2'b10: begin
                  ALUctrl = {1'b0, funct3}; 
                  if((funct3 == 0 | funct3 == 5) & (funct7)) ALUctrl = ALUctrl + 4'b1000; 
           end

           2'b11: begin 
                  ALUctrl = {1'b0, funct3};  
                  if(funct3 == 5 & funct7) ALUctrl = ALUctrl + 4'b1000; 
           end

           default: ALUctrl = 4'b1111;
        endcase 
    end
endmodule
