`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2026 21:53:55
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit(
    input [4:0] rs1_out, rs2_out, 
    input [4:0] rd_out_mem,
    input mem_read_out, reg_write_out, 
    output forward_a, forward_b

    );
    
    wire fwd = (~mem_read_out & reg_write_out & (rd_out_mem != 5'b0)); 
    assign forward_a = fwd & (rs1_out == rd_out_mem);
    assign forward_b = fwd & (rs2_out == rd_out_mem);
endmodule
