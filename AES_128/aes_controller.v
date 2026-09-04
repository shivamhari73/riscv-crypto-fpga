module aes_controller (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    output reg  [3:0] round_cnt,
    output reg        load_init,
    output reg        round_en,
    output reg        is_final_round,
    output reg        busy,
    output reg        done
);
    localparam S_IDLE   = 3'd0;
    localparam S_INIT   = 3'd1;
    localparam S_ROUNDS = 3'd2;
    localparam S_FINAL  = 3'd3;
    localparam S_DONE   = 3'd4;

    reg [2:0] state, next_state;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Round counter tracking (1 to 10)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round_cnt <= 4'd0;
        end else begin
            case (state)
                S_IDLE:   round_cnt <= 4'd0;
                S_INIT:   round_cnt <= 4'd1;
                S_ROUNDS: round_cnt <= round_cnt + 1'b1;
                default: ;
            endcase
        end
    end

    // Next-state and output control logic
    always @(*) begin
        next_state     = state;
        load_init      = 1'b0;
        round_en       = 1'b0;
        is_final_round = 1'b0;
        busy           = 1'b1;
        done           = 1'b0;

        case (state)
            S_IDLE: begin
                busy = 1'b0;
                if (start)
                    next_state = S_INIT;
            end

            S_INIT: begin
                load_init  = 1'b1; // Load plaintext ^ initial key
                next_state = S_ROUNDS;
            end

            S_ROUNDS: begin
                round_en = 1'b1;
                if (round_cnt == 4'd9)
                    next_state = S_FINAL;
            end

            S_FINAL: begin
                round_en       = 1'b1;
                is_final_round = 1'b1; // Round 10: Omit MixColumns
                next_state     = S_DONE;
            end

            S_DONE: begin
                busy = 1'b0;
                done = 1'b1;
                if (start)
                    next_state = S_INIT;
            end

            default: next_state = S_IDLE;
        endcase
    end

endmodule