`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 18:14:39
// Design Name: 
// Module Name: pc
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


module pc(
    input clk,
    input reset,
    input stall,
    input [31:0] pc_next,
    output reg [31:0] pc

    );
    
    always@(posedge clk) begin
        if (~reset) pc <= 32'b0;
        else if((pc_next <128) & !stall) pc <= pc_next;
        else pc <= pc;
        
    end
    
endmodule
