//============================================================================
// sha1_regif.v  -  Memory-mapped register interface (CPU side)
//
//  Bus protocol (PicoRV32-native style, easy to adapt to Wishbone/AXI-Lite):
//     bus_valid  : request (hold until bus_ready)
//     bus_we     : 1 = write, 0 = read
//     bus_addr   : byte offset within the peripheral (word aligned)
//     bus_ready  : 1-cycle pulse, access done; bus_rdata valid in that cycle
//
//  Register map (byte offsets)
//   0x00 CTRL    W : [0] INIT      start a new message (clears ERR/DONE)
//                    [1] FINISH    end of message, pad & hash the rest
//                    [9:8] LASTBYTES  valid bytes in LASTW (0..3), used w/ FINISH
//                    [4] IRQ_EN    interrupt enable (stored)
//                R : [4] IRQ_EN
//   0x04 STATUS  R : [0] READY  can accept WDATA / FINISH
//                    [1] BUSY   blocks being hashed
//                    [2] DONE   digest valid
//                    [3] ERR    sticky: write while not READY (cleared by INIT)
//   0x08 WDATA   W : push one full 32-bit word (first byte in bits 31:24)
//   0x0C LASTW   W : residual bytes, left aligned (write before FINISH)
//   0x20..0x30 DIGEST0..DIGEST4  R : H0..H4  (valid when DONE=1)
//========================================================================
module sha1_regif (
    input  wire         clk,
    input  wire         rst_n,

    // CPU bus
    input  wire         bus_valid,
    input  wire         bus_we,
    input  wire [7:0]   bus_addr,
    input  wire [31:0]  bus_wdata,
    output reg          bus_ready,
    output reg  [31:0]  bus_rdata,

    // to sha1_padder
    output wire         ctl_start,
    output wire         word_valid,
    output wire [31:0]  word_data,
    output wire         fin_valid,
    output wire [31:0]  fin_data,
    output wire [1:0]   fin_nbytes,

    // from sha1_padder / core
    input  wire         in_ready,
    input  wire         busy,
    input  wire         done,
    input  wire [159:0] digest,

    output wire         irq
);

    localparam [7:0] A_CTRL   = 8'h00,
                     A_STATUS = 8'h04,
                     A_WDATA  = 8'h08,
                     A_LASTW  = 8'h0C,
                     A_DIG0   = 8'h20,
                     A_DIG1   = 8'h24,
                     A_DIG2   = 8'h28,
                     A_DIG3   = 8'h2C,
                     A_DIG4   = 8'h30;

    // one access per request (first cycle, before ready)
    wire access = bus_valid & ~bus_ready;
    wire wr     = access &  bus_we;
    wire rd     = access & ~bus_we;

    wire wr_ctrl  = wr & (bus_addr == A_CTRL);
    wire wr_wdata = wr & (bus_addr == A_WDATA);
    wire wr_lastw = wr & (bus_addr == A_LASTW);

    wire cmd_init   = wr_ctrl & bus_wdata[0];
    wire cmd_finish = wr_ctrl & bus_wdata[1] & ~bus_wdata[0];   // INIT wins

    reg [31:0] lastw;
    reg        irq_en;
    reg        err;

    assign ctl_start  = cmd_init;
    assign word_valid = wr_wdata & in_ready;
    assign word_data  = bus_wdata;
    assign fin_valid  = cmd_finish & in_ready;
    assign fin_data   = lastw;
    assign fin_nbytes = bus_wdata[9:8];
    assign irq        = done & irq_en;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bus_ready <= 1'b0;
            bus_rdata <= 32'd0;
            lastw     <= 32'd0;
            irq_en    <= 1'b0;
            err       <= 1'b0;
        end else begin
            bus_ready <= bus_valid & ~bus_ready;

            if (wr_lastw) lastw  <= bus_wdata;
            if (wr_ctrl)  irq_en <= bus_wdata[4];

            if (cmd_init)
                err <= 1'b0;
            else if ((wr_wdata | cmd_finish) & ~in_ready)
                err <= 1'b1;

            if (access) begin
                case (bus_addr)
                    A_CTRL:   bus_rdata <= {27'd0, irq_en, 4'd0};
                    A_STATUS: bus_rdata <= {28'd0, err, done, busy, in_ready};
                    A_DIG0:   bus_rdata <= digest[159:128];
                    A_DIG1:   bus_rdata <= digest[127:96];
                    A_DIG2:   bus_rdata <= digest[95:64];
                    A_DIG3:   bus_rdata <= digest[63:32];
                    A_DIG4:   bus_rdata <= digest[31:0];
                    default:  bus_rdata <= 32'd0;
                endcase
            end
        end
    end

endmodule
