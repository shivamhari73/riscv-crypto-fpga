`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 19:25:35
// Design Name: 
// Module Name: mux_1
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


module mux_1(
    input pc_src,
    input [31:0]pc_n1,
    input [31:0] pc_n2,
    output [31:0] pc_next
    );
    
    assign pc_next = (pc_src)? pc_n2 : pc_n1; 
endmodule
