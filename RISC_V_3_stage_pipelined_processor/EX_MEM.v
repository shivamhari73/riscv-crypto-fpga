`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2026 19:21:56
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
    input clk, rst_n, stall,
    input  [31:0] alu_outi,
    input  [31:0] rs2_in,                 // forwarded rs2 (store data)
    input         reg_write_in, mem_write_in, mem_read_in,mem_to_reg_in,
    input  [4:0]  rd_in,
    output reg [31:0] alu_out,
    output reg [31:0] rs2_out,
    output reg        reg_write_out, mem_write_out, mem_read_out, mem_to_reg_out,
    output reg [4:0]  rd_out
);
    always @(posedge clk) begin
        if (!rst_n || stall) begin        // bubble
            alu_out       <= 32'b0;
            rs2_out       <= 32'b0;
            reg_write_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_read_out  <= 1'b0;
            rd_out        <= 5'b0;
            mem_to_reg_out <= 1'b0;
        end else begin
            alu_out       <= alu_outi;
            rs2_out       <= rs2_in;
            reg_write_out <= reg_write_in;
            mem_write_out <= mem_write_in;
            mem_read_out  <= mem_read_in;
            rd_out        <= rd_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule
