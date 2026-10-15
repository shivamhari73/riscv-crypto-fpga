`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.09.2026 12:08:14
// Design Name: 
// Module Name: reg_file
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


module reg_file(
    input clk,
    input rst_n,
    input wre,
    input [4:0] rs1, rs2, rd,
    output [31:0] a, rs2d,
    input [31:0] alu_out
    );
    
    reg [31:0] rf [31:0];
    
    assign a = (rs1 == 5'b0)? 32'b0 : rf[rs1];
    assign rs2d = (rs2 == 5'b0)? 32'b0 : rf[rs2];

    
    always@(posedge clk)
    if (!rst_n) begin
        rf[0] <=31'b0;
        rf[1] <=31'b0;
        rf[2] <=31'b0;
        rf[3] <=31'b0;
        rf[4] <=31'b0;
        rf[5] <=31'b0;
        rf[6] <=31'b0;
        rf[7] <=31'b0;
        rf[8] <=31'b0;
        rf[9] <=31'b0;
        rf[10] <=31'b0;
        rf[11] <=31'b0;
        rf[12] <=31'b0;
        rf[13] <=31'b0;
        rf[14] <=31'b0;
        rf[15] <=31'b0;
        rf[16] <=31'b0;
        rf[17] <=31'b0;
        rf[18] <=31'b0;
        rf[19] <=31'b0;
        rf[20] <=31'b0;
        rf[21] <=31'b0;
        rf[22] <=31'b0;
        rf[23] <=31'b0;
        rf[24] <=31'b0;
        rf[25] <=31'b0;
        rf[26] <=31'b0;
        rf[27] <=31'b0;
        rf[28] <=31'b0;
        rf[29] <=31'b0;
        rf[30] <=31'b0;
        rf[31] <=31'b0;        
        end
    else if (wre && (rd!=5'b0)) rf[rd] <= alu_out;
     
endmodule
