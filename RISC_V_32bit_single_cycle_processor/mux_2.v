`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 15:32:48
// Design Name: 
// Module Name: mux_2
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


module mux_2(
    input [31:0] rs2d,
    input [31:0] imm,
    input ALUsrc,
    output reg [31:0] b
    );
    
    always @ (*) begin
        case(ALUsrc) 
            1'b0: b = rs2d;
            1'b1: b = imm;
        default: b = 32'b0;
        endcase
        
    end
endmodule
