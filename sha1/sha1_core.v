//============================================================================
// sha1_core.v  -  SHA-1 (FIPS 180-4) block-processing core
//
//  * Processes one 512-bit block in 80 clock cycles (1 round / cycle)
//  * W[t] is generated on the fly with a 16-word sliding window (low area)
//  * Message padding is NOT done here - feed already-padded 512-bit blocks
//
//  Usage:
//    - First block of a message : assert `init`  for 1 cycle with `block`
//    - Following blocks         : assert `next`  for 1 cycle with `block`
//    - Wait for `ready` = 1 (and `digest_valid` = 1 for the final result)
//    - Block word 0 is block[511:480] (big-endian, as in the standard)
//============================================================================
module sha1_core (
    input  wire         clk,
    input  wire         rst_n,        // active-low asynchronous reset
    input  wire         init,         // start new message  (loads IV)
    input  wire         next,         // continue message   (uses current H)
    input  wire [511:0] block,        // padded 512-bit message block
    output wire         ready,        // core idle, can accept a block
    output wire [159:0] digest,       // {H0,H1,H2,H3,H4}
    output wire         digest_valid  // digest holds result of last block
);

    // ---------------- constants ----------------
    localparam [31:0] H0_INIT = 32'h67452301;
    localparam [31:0] H1_INIT = 32'hEFCDAB89;
    localparam [31:0] H2_INIT = 32'h98BADCFE;
    localparam [31:0] H3_INIT = 32'h10325476;
    localparam [31:0] H4_INIT = 32'hC3D2E1F0;

    localparam [31:0] K0 = 32'h5A827999;   // rounds  0-19
    localparam [31:0] K1 = 32'h6ED9EBA1;   // rounds 20-39
    localparam [31:0] K2 = 32'h8F1BBCDC;   // rounds 40-59
    localparam [31:0] K3 = 32'hCA62C1D6;   // rounds 60-79

    localparam IDLE  = 1'b0;
    localparam ROUND = 1'b1;

    // ---------------- registers ----------------
    reg         state;
    reg  [6:0]  t;                    // round counter 0..79
    reg  [31:0] a, b, c, d, e;        // working variables
    reg  [31:0] h0, h1, h2, h3, h4;   // chaining value
    reg  [31:0] w [0:15];             // message schedule window
    reg         valid;

    integer i;

    // ---------------- helper functions ----------------
    function [31:0] rotl;
        input [31:0] x;
        input integer n;
        begin
            rotl = (x << n) | (x >> (32 - n));
        end
    endfunction

    // ---------------- combinational datapath ----------------
    // Message schedule
    wire [31:0] w_new = rotl(w[13] ^ w[8] ^ w[2] ^ w[0], 1);
    wire [31:0] wt    = (t < 7'd16) ? w[0] : w_new;

    // Round function f and constant K
    reg [31:0] f, k;
    always @(*) begin
        if (t < 7'd20) begin
            f = (b & c) | (~b & d);                 // Ch
            k = K0;
        end else if (t < 7'd40) begin
            f = b ^ c ^ d;                          // Parity
            k = K1;
        end else if (t < 7'd60) begin
            f = (b & c) | (b & d) | (c & d);        // Maj
            k = K2;
        end else begin
            f = b ^ c ^ d;                          // Parity
            k = K3;
        end
    end

    wire [31:0] temp = rotl(a, 5) + f + e + k + wt;

    // ---------------- outputs ----------------
    assign ready        = (state == IDLE);
    assign digest       = {h0, h1, h2, h3, h4};
    assign digest_valid = valid;

    // ---------------- sequential logic ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            t     <= 7'd0;
            valid <= 1'b0;
            a <= 32'd0; b <= 32'd0; c <= 32'd0; d <= 32'd0; e <= 32'd0;
            h0 <= H0_INIT; h1 <= H1_INIT; h2 <= H2_INIT;
            h3 <= H3_INIT; h4 <= H4_INIT;
            for (i = 0; i < 16; i = i + 1) w[i] <= 32'd0;
        end else begin
            case (state)
            //------------------------------------------------------------
            IDLE: begin
                if (init | next) begin
                    // choose starting chaining value
                    if (init) begin
                        h0 <= H0_INIT; h1 <= H1_INIT; h2 <= H2_INIT;
                        h3 <= H3_INIT; h4 <= H4_INIT;
                        a  <= H0_INIT; b  <= H1_INIT; c  <= H2_INIT;
                        d  <= H3_INIT; e  <= H4_INIT;
                    end else begin
                        a <= h0; b <= h1; c <= h2; d <= h3; e <= h4;
                    end
                    // load message words (word 0 = MSB)
                    for (i = 0; i < 16; i = i + 1)
                        w[i] <= block[511 - 32*i -: 32];
                    t     <= 7'd0;
                    valid <= 1'b0;
                    state <= ROUND;
                end
            end
            //------------------------------------------------------------
            ROUND: begin
                // slide the schedule window
                for (i = 0; i < 15; i = i + 1) w[i] <= w[i+1];
                w[15] <= wt;

                if (t == 7'd79) begin
                    // final round: fold result into chaining value
                    h0 <= h0 + temp;
                    h1 <= h1 + a;
                    h2 <= h2 + rotl(b, 30);
                    h3 <= h3 + c;
                    h4 <= h4 + d;
                    valid <= 1'b1;
                    state <= IDLE;
                end else begin
                    e <= d;
                    d <= c;
                    c <= rotl(b, 30);
                    b <= a;
                    a <= temp;
                    t <= t + 7'd1;
                end
            end
            endcase
        end
    end

endmodule
