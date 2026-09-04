module key_expansion (
input wire [127:0] key_in,
input wire [3:0] round_idx, 
output wire [127:0] key_out
);

wire [31:0] w0 = key_in[127:96];
wire [31:0] w1 = key_in[95:64];
wire [31:0] w2 = key_in[63:32];
wire [31:0] w3 = key_in[31:0];


wire [7:0] rot_b0 = w3[23:16];
wire [7:0] rot_b1 = w3[15:8];
wire [7:0] rot_b2 = w3[7:0];
wire [7:0] rot_b3 = w3[31:24];

wire [7:0] sub_b0, sub_b1, sub_b2, sub_b3;
sbox u_sb0 (.in(rot_b0), .out(sub_b0));
sbox u_sb1 (.in(rot_b1), .out(sub_b1));
sbox u_sb2 (.in(rot_b2), .out(sub_b2));
sbox u_sb3 (.in(rot_b3), .out(sub_b3));
wire [31:0] subword_rot = {sub_b0, sub_b1, sub_b2, sub_b3};

reg [7:0] rcon;
always @(*) begin
case (round_idx)
4'd1: rcon = 8'h01;
4'd2: rcon = 8'h02;
4'd3: rcon = 8'h04;
4'd4: rcon = 8'h08;
4'd5: rcon = 8'h10;
4'd6: rcon = 8'h20;
4'd7: rcon = 8'h40;
4'd8: rcon = 8'h80;
4'd9: rcon = 8'h1b;
4'd10: rcon = 8'h36;
default: rcon = 8'h00;
endcase
end
wire [31:0] rcon_word = {rcon, 24'h000000};

wire [31:0] next_w0 = w0 ^ subword_rot ^ rcon_word;
wire [31:0] next_w1 = w1 ^ next_w0;
wire [31:0] next_w2 = w2 ^ next_w1;
wire [31:0] next_w3 = w3 ^ next_w2;
assign key_out = {next_w0, next_w1, next_w2, next_w3};
endmodule


     