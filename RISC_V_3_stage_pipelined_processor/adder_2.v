`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 19:23:04
// Design Name: 
// Module Name: adder_2
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


module adder_2(
    input [31:0]pc,
    input [31:0] imm,
    output [31:0]pc_n2 

    );
    
    assign pc_n2 = pc + imm;
endmodule
