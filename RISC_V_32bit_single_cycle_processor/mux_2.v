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
    input [31:0] imm, rdd_out,
    input ALUsrc,
    input forward_b,
    output reg [31:0] b
    );
    
    always @ (*) begin
        case({forward_b, ALUsrc}) 
            2'b00: b = rs2d;
            2'b01: b = imm;
            2'b10: b = rdd_out;
        default: b = 32'b0;
        endcase
        
    end
endmodule
