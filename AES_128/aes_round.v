module aes_round (
    input  wire [127:0] in,
    input  wire [127:0] round_key,
    input  wire         is_final_round,
    output wire [127:0] out
);

    wire [127:0]sb_out;
    wire [127:0]sr_out;
    wire [127:0]mc_out;
    wire [127:0]mux_out;

    sub_bytes sb1(.in(in),.out(sb_out));
    Shift_rows sr1(.in(sb_out),.out(sr_out));
    mix_columns mc1(.in(sr_out),.out(mc_out));

    assign mux_out=(is_final_round)?sr_out:mc_out;

    addroundkey ark(.in(mux_out),.round_key(round_key),.out(out));
endmodule