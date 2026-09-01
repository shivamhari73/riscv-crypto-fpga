module sub_byte(
    input wire [127:0]in;
    output reg [127:0]out;
);


//module sbox (
    //input  wire [7:0] in,
    //output reg  [7:0] out
);
sbox s0  (.in(in[7:0]),     .out(out[7:0]));
sbox s1  (.in(in[15:8]),    .out(out[15:8]));
sbox s2  (.in(in[23:16]),   .out(out[23:16]));
sbox s3  (.in(in[31:24]),   .out(out[31:24]));
sbox s4  (.in(in[39:32]),   .out(out[39:32]));
sbox s5  (.in(in[47:40]),   .out(out[47:40]));
sbox s6  (.in(in[55:48]),   .out(out[55:48]));
sbox s7  (.in(in[63:56]),   .out(out[63:56]));
sbox s8  (.in(in[71:64]),   .out(out[71:64]));
sbox s9  (.in(in[79:72]),   .out(out[79:72]));
sbox s10 (.in(in[87:80]),  .out(out[87:80]));
sbox s11 (.in(in[95:88]),  .out(out[95:88]));
sbox s12 (.in(in[103:96]), .out(out[103:96]));
sbox s13 (.in(in[111:104]),.out(out[111:104]));
sbox s14 (.in(in[119:112]),.out(out[119:112]));
sbox s15 (.in(in[127:120]),.out(out[127:120]));
endmodule 

