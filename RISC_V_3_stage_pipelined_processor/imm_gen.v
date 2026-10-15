`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 18:31:26
// Design Name: 
// Module Name: imm_gen
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


module imm_gen(
    input [31:0] instr,
    output reg signed[31:0] imm
    );
    wire [6:0] opcode = instr [6:0];
    parameter [6:0] lw = 7'b0000011, addi = 7'b0010011, 
                    sw = 7'b0100011, branch = 7'b1100011;
    always@(*) begin
        case(opcode) 
            addi, lw: imm = {{20{instr[31]}}, instr[31:20]};
            sw: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            branch: imm = {{19{instr[31]}}, instr[31], instr[7],
                             instr[30:25], instr[11:8], 1'b0};
        default: imm = 32'b0;
        endcase
    end                 

endmodule
