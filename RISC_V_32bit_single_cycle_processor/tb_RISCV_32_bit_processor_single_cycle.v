`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2026 01:53:10
// Design Name: 
// Module Name: tb_RISCV_32_bit_processor_single_cycle
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


module tb_RISCV_32_bit_processor_single_cycle;

    // Inputs
    reg clk;
    reg rst_n;

    // Outputs
    wire [31:0] alu_result;

    // Instantiate the Unit Under Test (UUT)
    RISCV_32_bit_processor_single_cycle uut (
        .clk(clk),
        .rst_n(rst_n),
        .alu_result(alu_result)  // Ensure port name matches your top module
    );

    // Clock Generation (100MHz clock -> 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;

        // Apply Reset (Hold reset low for 20ns)
        #20;
        rst_n = 1;

        // Monitor processor execution in simulation console
        $display("Time\t rst_n\t PC\t\t Instruction\t ALU Result");
        $monitor("%0dt\t %b\t 0x%h\t 0x%h\t 0x%h", 
                 $time, rst_n, uut.pc_o, uut.instr, alu_result);

        // Run simulation for 200ns (enough cycles for the instruction sequence)
        #200;

        $display("Simulation finished successfully.");
        $finish;
    end

endmodule

