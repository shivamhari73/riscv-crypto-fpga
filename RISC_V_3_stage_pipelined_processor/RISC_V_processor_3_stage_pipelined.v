`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2026 19:02:50
// Design Name: 
// Module Name: RISC_V_processor_3_stage_pipelined
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


module RISC_V_processor_3_stage_pipelined(
    input clk, rst_n,
    output [31:0] alu_out_f
    );
    
    wire [31:0]alu_out;
    
    assign alu_out_f = alu_out;
    wire stall;
    wire [31:0] pc_in, pc_next;
    pc pc_m(.clk(clk), .reset(rst_n), .stall(stall), .pc_next(pc_next), .pc(pc_in));
    
    wire [31:0] instr_in;
    instruction_memory instr_mem_m(.readAddr(pc_in), .instr(instr_in));
    
    wire PCsel;
    wire flush = PCsel & ~stall;
    wire [31:0] pc_out, instr_out;
    wire [4:0] rs1, rs2, rd;
    wire [6:0] opcode;
    IF_EX IF_EX_m(.clk(clk), .rst_n(rst_n), .flush(flush),
                .stall(stall), .pc_in(pc_in), .instr_in(instr_in),
                .pc_out(pc_out), .instr_out(instr_out), .rs1(rs1),
                .rs2(rs2), .rd(rd), .opcode(opcode));
    
    wire [31:0] imm;
    imm_gen imm_gen_m(.instr(instr_out), .imm(imm));
    
    wire reg_write_out;
    wire [4:0]rd_out;
    wire [31:0] write_data;
    wire [31:0] rs1d, rs2d;
    reg_file reg_file_m(.clk(clk), .rst_n(rst_n), .wre(reg_write_out), 
                        .rs1(rs1), .rs2(rs2), .rd(rd_out), .a(rs1d), 
                        .rs2d(rs2d), .alu_out(write_data));  
    
    wire zero;
    wire ALUsrc, mem_to_reg_in, reg_write_in, mem_read_in, mem_write_in, branch;
    wire [1:0] ALUop; 
    control control_m(.zero(zero), .ALUsrc(ALUsrc), .MemtoReg(mem_to_reg_in),
                      .Regwrite(reg_write_in), .Memread(mem_read_in), 
                      .Memwrite(mem_write_in), .Branch(branch), .ALUop(ALUop), 
                      .PCsel(PCsel), .instr(opcode));    
    
    
    wire [31:0] pc_n2;
    adder_2 adder_2_m(.pc(pc_out), .pc_n2(pc_n2), .imm(imm));
    
    wire [31:0] pc_n1;
    adder_1 adder_1_m(.pc(pc_in), .pc_n1(pc_n1));
    
    mux_1 mux_1_m(.pc_n1(pc_n1), .pc_n2(pc_n2), .pc_next(pc_next), .pc_src(PCsel));
    
    
    wire [3:0] ALUctrl;
    ALUctrl ALUctrl_m(.ALUOp(ALUop), .funct3(instr_out[14:12]), .funct7(instr_out[30]),
                      .ALUctrl(ALUctrl) );
    
    wire forward_a, forward_b;
    wire [31:0] a, b, rdd_out;
    mux_4 mux_4_m(.forward_a(forward_a), .rs1d(rs1d), .a(a), .rdd_out(alu_out));
    
    mux_2 mux_2_m(.rs2d(rs2d), .imm(imm), .rdd_out(alu_out), .ALUsrc(ALUsrc),
                  .forward_b(forward_b), .b(b));
    

    
    wire [31:0]alu_outi;
    wire negative, overflow;
    alu alu_m(.ALUctrl(ALUctrl), .a(a), .b(b), .alu_out(alu_outi),
              .negative(negative), .overflow(overflow), .zero(zero));
              

    wire mem_read_out;
    forwarding_unit forward_unit_m(.rd_out_mem(rd_out), .mem_read_out(mem_read_out),
                                   .reg_write_out(reg_write_out), .rs1_out(rs1), .rs2_out(rs2),
                                   .forward_a(forward_a), .forward_b(forward_b));
                                   
    hazard_unit hazard_unit_m(.rs1(rs1), .rs2(rs2), .rd_out(rd_out),
                            .mem_read_out(mem_read_out), .opcode(opcode), .stall(stall));
                            
    wire [31:0]rs2d_out;
    wire mem_to_reg_out, mem_write_out;
    wire [31:0] rs2_f = forward_b ? alu_out : rs2d;
    EX_MEM EX_MEM_m(.clk(clk), .rst_n(rst_n), .stall(stall), .rs2_in(rs2_f), 
                    .alu_outi(alu_outi), .mem_read_in(mem_read_in), .reg_write_in(reg_write_in),
                    .mem_write_in(mem_write_in), .rd_in(rd), .mem_to_reg_in(mem_to_reg_in),
                    .alu_out(alu_out), .mem_read_out(mem_read_out), 
                    .reg_write_out(reg_write_out), .mem_to_reg_out(mem_to_reg_out),
                   .mem_write_out(mem_write_out), .rd_out(rd_out), .rs2_out(rs2d_out));
   
    wire [31:0] read_data;
    data_mem data_mem_m(.clk(clk), .rst(rst_n), .memWrite(mem_write_out), 
                        .memRead(mem_read_out), .address(alu_out), .writeData(rs2d_out),
                        .readData(read_data));
                       
    mux_3 mux_3_m(.MemtoReg(mem_to_reg_out), .alu_out(alu_out), .read_data(read_data), 
                  .write_data(write_data));
endmodule
