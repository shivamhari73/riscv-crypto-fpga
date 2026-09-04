`timescale 1ns / 1ps

module aes_tb;
    reg         clk;
    reg         rst_n;
    reg         sel;
    reg         wr_en;
    reg  [5:0]  addr;
    reg  [31:0] wr_data;
    wire [31:0] rd_data;

    aes_peripheral uut (
        .clk     (clk),
        .rst_n   (rst_n),
        .sel     (sel),
        .wr_en   (wr_en),
        .addr    (addr),
        .wr_data (wr_data),
        .rd_data (rd_data)
    );

    // Clock generator: 100 MHz (10 ns period)
    always #5 clk = ~clk;

    // Drive inputs on negedge to avoid simulator race conditions
    task mmio_write(input [5:0] target_addr, input [31:0] data);
        begin
            @(negedge clk);
            sel     = 1'b1;
            wr_en   = 1'b1;
            addr    = target_addr;
            wr_data = data;
            @(negedge clk);
            sel     = 1'b0;
            wr_en   = 1'b0;
        end
    endtask

    task mmio_read(input [5:0] target_addr, output [31:0] data);
        begin
            @(negedge clk);
            sel     = 1'b1;
            wr_en   = 1'b0;
            addr    = target_addr;
            #1;
            data    = rd_data;
            @(negedge clk);
            sel     = 1'b0;
        end
    endtask

    reg [31:0] status_val;
    reg [31:0] out0, out1, out2, out3;
    reg [127:0] actual_ciphertext;
    integer cycle_count;
    localparam [127:0] EXPECTED_CIPHERTEXT = 128'h3925841d02dc09fbdc118597196a0b32;

    initial begin
        $display("Starting AES-128 Accelerator Test (NIST FIPS-197 App B)...");
        clk     = 1'b0;
        rst_n   = 1'b0;
        sel     = 1'b0;
        wr_en   = 1'b0;
        addr    = 6'd0;
        wr_data = 32'd0;

        // Reset
        #30;
        @(negedge clk);
        rst_n = 1'b1;
        #20;

        // Write Plaintext: 3243f6a8 885a308d 313198a2 e0370734
        $display("[CPU] Writing Plaintext...");
        mmio_write(6'h0c, 32'h3243f6a8); // DATA3
        mmio_write(6'h08, 32'h885a308d); // DATA2
        mmio_write(6'h04, 32'h313198a2); // DATA1
        mmio_write(6'h00, 32'he0370734); // DATA0

        // Write Key: 2b7e1516 28aed2a6 abf71588 09cf4f3c
        $display("[CPU] Writing Key...");
        mmio_write(6'h1c, 32'h2b7e1516); // KEY3
        mmio_write(6'h18, 32'h28aed2a6); // KEY2
        mmio_write(6'h14, 32'habf71588); // KEY1
        mmio_write(6'h10, 32'h09cf4f3c); // KEY0

        // Trigger Start
        $display("[CPU] Triggering Start...");
        mmio_write(6'h20, 32'h00000001);

        // Poll status register with a guaranteed timeout
        status_val  = 32'd0;
        cycle_count = 0;
        while ((status_val & 32'h2) == 32'h0 && cycle_count < 100) begin
            mmio_read(6'h24, status_val);
            cycle_count = cycle_count + 1;
        end

        if (cycle_count >= 100) begin
            $display(">>> TEST FAILED: Polling timed out! STATUS = 0x%08h <<<", status_val);
            $finish;
        end

        $display("[CPU] Encryption complete in %0d poll cycles!", cycle_count);

        // Read result registers
        mmio_read(6'h34, out3);
        mmio_read(6'h30, out2);
        mmio_read(6'h2c, out1);
        mmio_read(6'h28, out0);

        actual_ciphertext = {out3, out2, out1, out0};

        $display("----------------------------------------------------------------");
        $display("Expected: %h", EXPECTED_CIPHERTEXT);
        $display("Actual:   %h", actual_ciphertext);
        $display("----------------------------------------------------------------");

        if (actual_ciphertext === EXPECTED_CIPHERTEXT)
            $display(">>> TEST PASSED: Output matches NIST standard 100%! <<<");
        else
            $display(">>> TEST FAILED: Ciphertext mismatch! <<<");

        $finish;
    end

endmodule