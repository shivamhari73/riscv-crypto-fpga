module aes_core (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output wire [127:0] ciphertext,
    output wire         busy,
    output wire         done
);
    wire [3:0]   round_cnt;
    wire         load_init;
    wire         round_en;
    wire         is_final_round;

    reg  [127:0] state_reg;
    reg  [127:0] round_key_reg;

    wire [127:0] init_out;
    wire [127:0] round_out;
    wire [127:0] next_key;


    aes_controller controller01 (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start),
        .round_cnt      (round_cnt),
        .load_init      (load_init),
        .round_en       (round_en),
        .is_final_round (is_final_round),
        .busy           (busy),
        .done           (done)
    );

    addroundkey ark01 (
        .in        (plaintext),
        .round_key (key),
        .out       (init_out)
    );

    key_expansion expansion01 (
        .key_in    (round_key_reg),
        .round_idx (round_cnt),
        .key_out   (next_key)
    );

    aes_round round01 (
        .in             (state_reg),
        .round_key      (next_key),
        .is_final_round (is_final_round),
        .out            (round_out)
    );

  
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg     <= 128'h0;
            round_key_reg <= 128'h0;
        end else if (load_init) begin
            state_reg     <= init_out;
            round_key_reg <= key;
        end else if (round_en) begin
            state_reg     <= round_out;
            round_key_reg <= next_key;
        end
    end

    assign ciphertext = state_reg;

endmodule