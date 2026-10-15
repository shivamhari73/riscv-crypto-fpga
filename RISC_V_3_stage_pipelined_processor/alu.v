`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.09.2026 15:00:54
// Design Name: 
// Module Name: alu
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


module alu(
    input [3:0]ALUctrl,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] alu_out,
    output zero, negative, overflow

    );
    parameter [3:0] add = 4'b0000, sll = 4'b0001, slt = 4'b0010, sltu = 4'b0011,
                    xorr = 4'b0100, srl = 4'b0101, orr = 4'b0110, andd = 4'b0111,
                    sub = 4'b1000, sra = 4'b1101;
   
   always@(*) begin
        case(ALUctrl)
            add: alu_out =  a + b;
            sll: alu_out = a << b[4:0];
            slt: alu_out = ($signed(a) < $signed(b))? 1 : 0;
            sltu: alu_out = (a < b)? 1:0;
            xorr: alu_out = a ^ b;
            srl: alu_out =  a >> b[4:0];
            orr: alu_out = a | b;
            andd: alu_out = a & b;
            sub: alu_out = a - b;
            sra: alu_out = $signed(a) >>> b;
        default: alu_out = 32'b0;
        endcase
    end
    assign zero = (alu_out == 0);
    assign negative = alu_out[31];
    assign overflow = (a[31] == b[31])? 1:0 ^ alu_out[31]; 
endmodule
