`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2026 00:14:02
// Design Name: 
// Module Name: 32_bit_RISCV_processor_single_cycle
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


module RISCV_32_bit_processor_3_stage_pipelined(
    input clk,
    input rst_n,
    output wire [31:0] alu_result
    );
    
    wire [31:0] alu_out;
    wire [31:0] pc_next, pc_o;   
    pc pc_m(clk, rst_n, pc_next, pc_o);
    
    wire [31:0] pc_n1;    
    adder_1 adder_pc4(pc_o, pc_n1);
    
    wire [31:0] imm_val;

    wire [31:0] pc_n2;   
    adder_2 adder_branch(pc_o,imm_val, pc_n2);
    
    wire PCsel;
    mux_1 mux_1_m(PCsel,pc_n1, pc_n2, pc_next);
    
    wire [31:0] instr;
    instruction_memory instr_mem(pc_o, instr);
    
    imm_gen imm_gen_m(instr, imm_val);
    
    wire ALUsrc, MemtoReg, Regwrite, Memread, Memwrite, Branch;
    wire [1:0] ALUop;
    wire zero;
    
    control control_m(instr[6:0], zero, ALUsrc, MemtoReg, Regwrite, 
            Memread, Memwrite, Branch, ALUop, PCsel);    
                
    wire [31:0] a, b, rs2d;
    wire [31:0] Writedata;
    reg_file reg_file_m(clk, rst_n, Regwrite, instr[19:15], instr[24:20], 
                        instr[11:7], a, rs2d , Writedata);
                        
    wire [3:0] ALUctl;
    ALUctrl ALUctrl_m(ALUop, instr[31:25], instr[14:12], ALUctl);
    
    wire negative, overflow;
   
    alu alu_m(ALUctl, a, b, alu_out, zero, negative, overflow);
    
    wire [31:0] Readdata;
    data_mem data_mem_m(rst_n, clk, Memwrite, Memread, alu_out, rs2d, Readdata);
    
    mux_2 mux_2_m(rs2d, imm_val, ALUsrc, b);
       
    mux_3 mux_3_m(MemtoReg, alu_out, Readdata, Writedata);
    
    assign alu_result = alu_out;
    
    
endmodule
