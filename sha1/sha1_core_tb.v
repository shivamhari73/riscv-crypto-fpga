`timescale 1ns/1ps
module sha1_tb;
    reg          clk = 0, rst_n = 0, init = 0, next = 0;
    reg  [511:0] block;
    wire         ready, digest_valid;
    wire [159:0] digest;

    sha1_core dut (.clk(clk), .rst_n(rst_n), .init(init), .next(next),
                   .block(block), .ready(ready),
                   .digest(digest), .digest_valid(digest_valid));

    always #5 clk = ~clk;

    integer errors = 0;

    task run_block(input is_init, input [511:0] blk);
    begin
        @(posedge clk); #1;
        block = blk; init = is_init; next = ~is_init;
        @(posedge clk); #1;
        init = 0; next = 0;
        wait (digest_valid);
        @(posedge clk); #1;
    end
    endtask

    task check(input [159:0] expected, input [255:0] name);
    begin
        if (digest === expected)
            $display("PASS  %0s : %h", name, digest);
        else begin
            $display("FAIL  %0s : got %h expected %h", name, digest, expected);
            errors = errors + 1;
        end
    end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        rst_n = 1;

        // Test 1: "abc"
        run_block(1, {32'h61626380, 416'd0, 64'h18});
        check(160'ha9993e364706816aba3e25717850c26c9cd0d89d, "abc");

        // Test 2: "" (empty string)
        run_block(1, {32'h80000000, 416'd0, 64'h0});
        check(160'hda39a3ee5e6b4b0d3255bfef95601890afd80709, "empty");

        // Test 3: "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" (2 blocks)
        run_block(1, 512'h6162636462636465636465666465666765666768666768696768696A68696A6B696A6B6C6A6B6C6D6B6C6D6E6C6D6E6F6D6E6F706E6F70718000000000000000);
        run_block(0, {448'd0, 64'h1C0});
        check(160'h84983e441c3bd26ebaae4aa1f95129e5e54670f1, "448-bit msg");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
