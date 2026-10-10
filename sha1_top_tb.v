`timescale 1ns/1ps
// Testbench: behaves like a CPU doing MMIO accesses to sha1_top
module sha1_top_tb;
    reg         clk = 0, rst_n = 0;
    reg         bus_valid = 0, bus_we = 0;
    reg  [7:0]  bus_addr = 0;
    reg  [31:0] bus_wdata = 0;
    wire        bus_ready, irq;
    wire [31:0] bus_rdata;

    sha1_top dut (.clk(clk), .rst_n(rst_n), .bus_valid(bus_valid), .bus_we(bus_we),
                  .bus_addr(bus_addr), .bus_wdata(bus_wdata), .bus_ready(bus_ready),
                  .bus_rdata(bus_rdata), .irq(irq));

    always #5 clk = ~clk;

    localparam CTRL=8'h00, STATUS=8'h04, WDATA=8'h08, LASTW=8'h0C, DIG0=8'h20;

    // ---------------- bus tasks ----------------
    reg [31:0] rd_data;

    task bus_write(input [7:0] a, input [31:0] d);
    begin
        @(posedge clk); #1;
        bus_valid = 1; bus_we = 1; bus_addr = a; bus_wdata = d;
        @(posedge clk); #1;
        while (!bus_ready) begin @(posedge clk); #1; end
        bus_valid = 0; bus_we = 0;
    end
    endtask

    task bus_read(input [7:0] a);
    begin
        @(posedge clk); #1;
        bus_valid = 1; bus_we = 0; bus_addr = a;
        @(posedge clk); #1;
        while (!bus_ready) begin @(posedge clk); #1; end
        rd_data = bus_rdata;
        bus_valid = 0;
    end
    endtask

    task wait_ready;                       // poll STATUS.READY
    begin
        bus_read(STATUS);
        while (!rd_data[0]) bus_read(STATUS);
    end
    endtask

    task wait_done;                        // poll STATUS.DONE
    begin
        bus_read(STATUS);
        while (!rd_data[2]) bus_read(STATUS);
    end
    endtask

    // ---------------- message source ----------------
    function [7:0] msg_byte(input integer i, input integer is_abc);
        reg [23:0] abc;
        begin
            abc = "abc";
            if (is_abc) msg_byte = abc[23 - 8*i -: 8];
            else        msg_byte = (i*7 + 3) & 8'hFF;
        end
    endfunction

    integer errors = 0;
    integer n_words, n_res, w, k;
    reg [31:0] word;
    reg [159:0] got;

    task run_test(input integer len, input integer is_abc, input [159:0] expected);
    begin
        n_words = len / 4;
        n_res   = len % 4;

        bus_write(CTRL, 32'h1);                         // INIT
        for (w = 0; w < n_words; w = w + 1) begin
            word = {msg_byte(4*w,is_abc), msg_byte(4*w+1,is_abc),
                    msg_byte(4*w+2,is_abc), msg_byte(4*w+3,is_abc)};
            wait_ready;
            bus_write(WDATA, word);
        end
        word = 32'd0;                                   // residual bytes, left aligned
        for (k = 0; k < n_res; k = k + 1)
            word = word | (msg_byte(4*n_words + k, is_abc) << (24 - 8*k));
        wait_ready;
        bus_write(LASTW, word);
        bus_write(CTRL, 32'h2 | (n_res << 8));          // FINISH
        wait_done;

        bus_read(DIG0);      got[159:128] = rd_data;
        bus_read(DIG0+8'h4); got[127:96]  = rd_data;
        bus_read(DIG0+8'h8); got[95:64]   = rd_data;
        bus_read(DIG0+8'hC); got[63:32]   = rd_data;
        bus_read(DIG0+8'h10);got[31:0]    = rd_data;
        bus_read(STATUS);

        if (got === expected && !rd_data[3])
            $display("PASS  len=%0d  %h", len, got);
        else begin
            $display("FAIL  len=%0d  got %h exp %h err=%b", len, got, expected, rd_data[3]);
            errors = errors + 1;
        end
    end
    endtask

    initial begin
        repeat (4) @(posedge clk);
        rst_n = 1;
        run_test(3, 1, 160'ha9993e364706816aba3e25717850c26c9cd0d89d);
        run_test(0, 0, 160'hda39a3ee5e6b4b0d3255bfef95601890afd80709);
        run_test(1, 0, 160'h9842926af7ca0a8cca12604f945414f07b01e13d);
        run_test(2, 0, 160'h1f5ae6b976eaa448d6756c593ceb816ac8799ef1);
        run_test(3, 0, 160'h4201de9f98cb0a9b8cf52398be7802b55d45266a);
        run_test(4, 0, 160'ha9ca94e2a9be52cdcef145facf2bad04e553cb0b);
        run_test(5, 0, 160'h941f194daa0adbdf8582dbf3691a6288329d2be6);
        run_test(55, 0, 160'hddf57317ef34bfee3b6df83d359098930eb278bc);
        run_test(56, 0, 160'ha0d492bb0fc889d0eca3bc137066ab6f4f74f369);
        run_test(57, 0, 160'h11a02dcf95859677a62e75024067c22b165d890f);
        run_test(60, 0, 160'h4a72dc48088734d6ee17cccbb158de29744e9733);
        run_test(63, 0, 160'hc55856749bef509bdfe6bfebfc7bf4e793e82132);
        run_test(64, 0, 160'hbede92be29c3874e1b54ddc77988d606fc857a8e);
        run_test(65, 0, 160'hb05a80522b053d6dc7e0a517d0e70212c7dad11f);
        run_test(119, 0, 160'h504e27376a6e0f0dba8295b85cb25dc4dfa17d23);
        run_test(120, 0, 160'h82134b02fb3f702491be9bed581eeab59334acb2);
        run_test(128, 0, 160'ha09133e6730ffe899efb70204cb5646cd5dc24ee);
        run_test(1000, 0, 160'h4231a8a50a10fa9758db8ec71fdef855b751048a);

        // error flag: writing a word while not READY must set ERR
        bus_write(CTRL, 32'h1);
        bus_write(CTRL, 32'h2);                         // empty message, now hashing
        bus_write(WDATA, 32'hDEADBEEF);                 // not ready -> ERR
        bus_read(STATUS);
        if (rd_data[3]) $display("PASS  ERR flag set on illegal write");
        else begin $display("FAIL  ERR flag"); errors = errors + 1; end
        wait_done;

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end

    initial begin #50_000_000; $display("TIMEOUT"); $finish; end
endmodule
