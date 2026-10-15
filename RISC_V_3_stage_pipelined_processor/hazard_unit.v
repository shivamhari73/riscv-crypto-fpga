`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2026 00:03:59
// Design Name: 
// Module Name: hazard_unit
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


module hazard_unit(
    input [6:0] opcode,
    input [4:0] rs1, rs2,
    input [4:0] rd_out,
    input mem_read_out,
    output stall

    );
    
    wire use_rs1 = (opcode == 7'b0110011) | (opcode == 7'b0100011)
                    | (opcode == 7'b0000011) | (opcode == 7'b1100011)
                    | (opcode == 7'b0010011);
    
    wire use_rs2 = (opcode == 7'b0110011) | (opcode == 7'b0100011)
                   | (opcode == 7'b1100011);
    
    assign stall = mem_read_out & (rd_out != 5'd0) &
                   ((use_rs1 & (rd_out == rs1)) |
                    (use_rs2 & (rd_out == rs2)));
endmodule
