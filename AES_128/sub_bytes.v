module sub_bytes (
input wire [127:0] in,
output wire [127:0] out
);
genvar i;
generate
for (i = 0; i < 16; i = i + 1) begin : gen_sbox
aes_sbox u_sbox (
.in(in[i*8 +: 8]),
.out(out[i*8 +: 8])
);
end
endgenerate
endmodule
