`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2026 19:07:45
// Design Name: 
// Module Name: IF_EX
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


module IF_EX(
    input clk, rst_n, flush, stall,
    input [31:0] pc_in,
    input [31:0] instr_in,
    output reg [31:0]  pc_out,
    output reg [31:0]  instr_out,
    output reg [4:0] rs1, rs2, rd,
    output reg [6:0] opcode
    );
    
    always @(posedge clk) begin
        if (!rst_n) begin
            pc_out <= 32'b0;
            instr_out <= 32'b0;
            opcode <= 7'b0;
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            rd <= 5'b0;
        end
        else if (flush) begin
            pc_out <= 32'b0;
            instr_out <= 32'b0;
            opcode <= 7'b0;
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            rd <= 5'b0;
        end   
        else if (!stall) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
            opcode <= instr_in [6:0];
            rs1 <= instr_in[19:15];
            rs2 <= instr_in[24:20];
            rd <= instr_in[11:7];       
        end
        else begin
            pc_out <= pc_out;
            instr_out <= instr_out;
            opcode <= instr_out [6:0];
            rs1 <= instr_out[19:15];
            rs2 <= instr_out[24:20];
            rd <= instr_out[11:7];  
        end
    end
endmodule
