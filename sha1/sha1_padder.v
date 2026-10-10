//============================================================================
// sha1_padder.v  -  Message padding + 512-bit block assembly + sequencing

module sha1_padder (
    input  wire         clk,
    input  wire         rst_n,

    // control / data from register interface
    input  wire         start,         // begin new message (aborts any current)
    input  wire         word_valid,    // push one full 32-bit word
    input  wire [31:0]  word_data,
    input  wire         fin_valid,     // end of message
    input  wire [31:0]  fin_data,      // residual bytes, left aligned
    input  wire [1:0]   fin_nbytes,    // 0..3 valid residual bytes

    // status
    output wire         in_ready,      // can accept word_valid / fin_valid
    output wire         busy,          // blocks are being hashed
    output wire         done,          // digest is final

    // to sha1_core
    output wire         core_init,
    output wire         core_next,
    output wire [511:0] core_block,
    input  wire         core_ready,
    input  wire         core_valid
);

    localparam [2:0] S_IDLE    = 3'd0,
                     S_COLLECT = 3'd1,   // gathering words
                     S_FLUSH   = 3'd2,   // waiting for core, send block
                     S_LENBLK  = 3'd3,   // build "length only" block
                     S_WAIT    = 3'd4,   // last block sent, wait for digest
                     S_DONE    = 3'd5;

    reg [2:0]  state;
    reg [3:0]  wc;                 // word index in current block (0..15)
    reg [31:0] blk_buf [0:15];     // block buffer
    reg [63:0] bitlen;             // message length in bits (full words so far)
    reg [63:0] len_reg;            // final length, kept for extra block
    reg        first_blk;          // next block is the first of the message
    reg        last_blk;           // block being flushed is the final one
    reg        len_pending;        // an extra length-only block is needed

    integer i;

    // ---------------- helpers ----------------
    // Insert the 0x80 delimiter right after the valid residual bytes
    function [31:0] pad_word;
        input [31:0] d;
        input [1:0]  n;
        begin
            case (n)
                2'd0:    pad_word = 32'h8000_0000;
                2'd1:    pad_word = {d[31:24], 8'h80, 16'h0000};
                2'd2:    pad_word = {d[31:16], 8'h80, 8'h00};
                default: pad_word = {d[31:8],  8'h80};
            endcase
        end
    endfunction

    wire [63:0] fin_len = bitlen + {59'd0, fin_nbytes, 3'b000};   // + 8*n

    // ---------------- outputs ----------------
    assign in_ready = (state == S_COLLECT);
    assign busy     = (state == S_FLUSH) | (state == S_LENBLK) | (state == S_WAIT);
    assign done     = (state == S_DONE);

    wire core_start = (state == S_FLUSH) & core_ready;
    assign core_init = core_start &  first_blk;
    assign core_next = core_start & ~first_blk;

    // pack buffer -> block, word 0 in MSBs
    genvar g;
    generate
        for (g = 0; g < 16; g = g + 1) begin : PACK
            assign core_block[511-32*g -: 32] = blk_buf[g];
        end
    endgenerate

    // ---------------- FSM ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            wc          <= 4'd0;
            bitlen      <= 64'd0;
            len_reg     <= 64'd0;
            first_blk   <= 1'b0;
            last_blk    <= 1'b0;
            len_pending <= 1'b0;
            for (i = 0; i < 16; i = i + 1) blk_buf[i] <= 32'd0;
        end else if (start) begin
            state       <= S_COLLECT;
            wc          <= 4'd0;
            bitlen      <= 64'd0;
            first_blk   <= 1'b1;
            last_blk    <= 1'b0;
            len_pending <= 1'b0;
            for (i = 0; i < 16; i = i + 1) blk_buf[i] <= 32'd0;
        end else begin
            case (state)
            //----------------------------------------------------------
            S_COLLECT: begin
                if (word_valid) begin
                    blk_buf[wc] <= word_data;
                    wc          <= wc + 4'd1;
                    bitlen      <= bitlen + 64'd32;
                    if (wc == 4'd15) state <= S_FLUSH;     // block full
                end else if (fin_valid) begin
                    blk_buf[wc] <= pad_word(fin_data, fin_nbytes);
                    len_reg     <= fin_len;
                    if (wc <= 4'd13) begin
                        // length fits in this block (words 14,15)
                        blk_buf[14] <= fin_len[63:32];
                        blk_buf[15] <= fin_len[31:0];
                        last_blk    <= 1'b1;
                        len_pending <= 1'b0;
                    end else begin
                        // padding spilled: need one more block for the length
                        last_blk    <= 1'b0;
                        len_pending <= 1'b1;
                    end
                    state <= S_FLUSH;
                end
            end
            //----------------------------------------------------------
            S_FLUSH: begin
                if (core_ready) begin                      // core takes block now
                    for (i = 0; i < 16; i = i + 1) blk_buf[i] <= 32'd0;
                    wc        <= 4'd0;
                    first_blk <= 1'b0;
                    if (len_pending)    state <= S_LENBLK;
                    else if (last_blk)  state <= S_WAIT;
                    else                state <= S_COLLECT;
                end
            end
            //----------------------------------------------------------
            S_LENBLK: begin
                blk_buf[14] <= len_reg[63:32];
                blk_buf[15] <= len_reg[31:0];
                last_blk    <= 1'b1;
                len_pending <= 1'b0;
                state       <= S_FLUSH;
            end
            //----------------------------------------------------------
            S_WAIT: begin
                if (core_ready & core_valid) state <= S_DONE;
            end
            //----------------------------------------------------------
            default: ;   // S_IDLE, S_DONE: wait for start
            endcase
        end
    end

endmodule
