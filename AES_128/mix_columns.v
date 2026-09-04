module mix_columns (
    input  [127:0] in,
    output [127:0] out
);

function [7:0] gm02;
    input [7:0] x;
    begin
        if (x[7])
            gm02 = (x << 1) ^ 8'h1B;
        else
            gm02 = x << 1;
    end
endfunction



wire [7:0] a0 = in[127:120];
wire [7:0] b0 = in[119:112];
wire [7:0] c0 = in[111:104];
wire [7:0] d0 = in[103:96];

wire [7:0] t0;

assign t0 = a0 ^ b0 ^ c0 ^ d0;

assign out[127:120] = a0 ^ t0 ^ gm02(a0 ^ b0);
assign out[119:112] = b0 ^ t0 ^ gm02(b0 ^ c0);
assign out[111:104] = c0 ^ t0 ^ gm02(c0 ^ d0);
assign out[103:96]  = d0 ^ t0 ^ gm02(d0 ^ a0);


wire [7:0] a1 = in[95:88];
wire [7:0] b1 = in[87:80];
wire [7:0] c1 = in[79:72];
wire [7:0] d1 = in[71:64];

wire [7:0] t1;

assign t1 = a1 ^ b1 ^ c1 ^ d1;

assign out[95:88] = a1 ^ t1 ^ gm02(a1 ^ b1);
assign out[87:80] = b1 ^ t1 ^ gm02(b1 ^ c1);
assign out[79:72] = c1 ^ t1 ^ gm02(c1 ^ d1);
assign out[71:64] = d1 ^ t1 ^ gm02(d1 ^ a1);


wire [7:0] a2 = in[63:56];
wire [7:0] b2 = in[55:48];
wire [7:0] c2 = in[47:40];
wire [7:0] d2 = in[39:32];

wire [7:0] t2;

assign t2 = a2 ^ b2 ^ c2 ^ d2;

assign out[63:56] = a2 ^ t2 ^ gm02(a2 ^ b2);
assign out[55:48] = b2 ^ t2 ^ gm02(b2 ^ c2);
assign out[47:40] = c2 ^ t2 ^ gm02(c2 ^ d2);
assign out[39:32] = d2 ^ t2 ^ gm02(d2 ^ a2);


wire [7:0] a3 = in[31:24];
wire [7:0] b3 = in[23:16];
wire [7:0] c3 = in[15:8];
wire [7:0] d3 = in[7:0];

wire [7:0] t3;

assign t3 = a3 ^ b3 ^ c3 ^ d3;

assign out[31:24] = a3 ^ t3 ^ gm02(a3 ^ b3);
assign out[23:16] = b3 ^ t3 ^ gm02(b3 ^ c3);
assign out[15:8]  = c3 ^ t3 ^ gm02(c3 ^ d3);
assign out[7:0]   = d3 ^ t3 ^ gm02(d3 ^ a3);

endmodule
// module mix_columns(
//     input [127:0]in;
//     output [127:0]out;
// );

// function [7:0]gm02 ;
//     input [7:0]x;
//     begin 
//         if(x[7]) gm02=(x<<1)^8'h1B;
//         else 
//         gm02=(x<<1);
//     end
// endfunction

// function [7:0]gm03 ;
//     input [7:0]x;
//     begin
//         gm03 = gm02(x) ^ x;
//     end
// endfunction


//     assign out[127:120]= gm02(in[127:120])^gm03(in[119:112])^in[111:104]^in[103: 96];
//     assign out[119:112]=in[127:120]^gm02(in[119:112])^gm03(in[111:104])^in[103: 96];
//     assign out[111:104]=in[127:120]^in[119:112]^gm02(in[111:104])^gm03(in[103: 96]);
//     assign out[103: 96]=gm03(in[127:120])^in[119:112]^in[111:104]^gm02(in[103: 96]);

//     assign out[95:88] = gm02(in[95:88]) ^ gm03(in[87:80]) ^ in[79:72] ^ in[71:64];
//     assign out[87:80] = in[95:88] ^ gm02(in[87:80]) ^ gm03(in[79:72]) ^ in[71:64];
//     assign out[79:72] = in[95:88] ^ in[87:80] ^ gm02(in[79:72]) ^ gm03(in[71:64]);
//     assign out[71:64] = gm03(in[95:88]) ^ in[87:80] ^ in[79:72] ^ gm02(in[71:64]);

//     assign out[63:56] = gm02(in[63:56]) ^ gm03(in[55:48]) ^ in[47:40] ^ in[39:32];
//     assign out[55:48] = in[63:56] ^ gm02(in[55:48]) ^ gm03(in[47:40]) ^ in[39:32];
//     assign out[47:40] = in[63:56] ^ in[55:48] ^ gm02(in[47:40]) ^ gm03(in[39:32]);
//     assign out[39:32] = gm03(in[63:56]) ^ in[55:48] ^ in[47:40] ^ gm02(in[39:32]);

//     assign out[31:24] = gm02(in[31:24]) ^ gm03(in[23:16]) ^ in[15:8] ^ in[7:0];
//     assign out[23:16] = in[31:24] ^ gm02(in[23:16]) ^ gm03(in[15:8]) ^ in[7:0];
//     assign out[15:8]  = in[31:24] ^ in[23:16] ^ gm02(in[15:8]) ^ gm03(in[7:0]);
//     assign out[7:0]   = gm03(in[31:24]) ^ in[23:16] ^ in[15:8] ^ gm02(in[7:0]);





// endmodule