//============================================================================
// sha1_top.v  -  SHA-1 hardware accelerator, bus-facing top level
//
//   CPU bus --> sha1_regif --> sha1_padder --> sha1_core
//                   ^                               |
//                   +------------- digest ----------+
//
//  Instantiate in your SoC and decode a 256-byte address window to bus_*.
//============================================================================
module sha1_top (
    input  wire         clk,
    input  wire         rst_n,

    // CPU-side bus (PicoRV32-native style)
    input  wire         bus_valid,
    input  wire         bus_we,        // = |mem_wstrb
    input  wire [7:0]   bus_addr,      // = mem_addr[7:0]
    input  wire [31:0]  bus_wdata,
    output wire         bus_ready,
    output wire [31:0]  bus_rdata,

    output wire         irq            // level, high while DONE & IRQ_EN
);

    wire         ctl_start, word_valid, fin_valid;
    wire [31:0]  word_data, fin_data;
    wire [1:0]   fin_nbytes;
    wire         in_ready, busy, done;

    wire         core_init, core_next, core_ready, core_valid;
    wire [511:0] core_block;
    wire [159:0] digest;

    sha1_regif u_regif (
        .clk(clk), .rst_n(rst_n),
        .bus_valid(bus_valid), .bus_we(bus_we), .bus_addr(bus_addr),
        .bus_wdata(bus_wdata), .bus_ready(bus_ready), .bus_rdata(bus_rdata),
        .ctl_start(ctl_start),
        .word_valid(word_valid), .word_data(word_data),
        .fin_valid(fin_valid), .fin_data(fin_data), .fin_nbytes(fin_nbytes),
        .in_ready(in_ready), .busy(busy), .done(done),
        .digest(digest), .irq(irq)
    );

    sha1_padder u_padder (
        .clk(clk), .rst_n(rst_n),
        .start(ctl_start),
        .word_valid(word_valid), .word_data(word_data),
        .fin_valid(fin_valid), .fin_data(fin_data), .fin_nbytes(fin_nbytes),
        .in_ready(in_ready), .busy(busy), .done(done),
        .core_init(core_init), .core_next(core_next), .core_block(core_block),
        .core_ready(core_ready), .core_valid(core_valid)
    );

    sha1_core u_core (
        .clk(clk), .rst_n(rst_n),
        .init(core_init), .next(core_next), .block(core_block),
        .ready(core_ready), .digest(digest), .digest_valid(core_valid)
    );

endmodule
