module aes_peripheral (
    input  wire        clk,
    input  wire        rst_n,

    // 32-bit MMIO Bus Interface
    input  wire        sel,
    input  wire        wr_en,
    input  wire [5:0]  addr,      // Word-aligned offsets 0x00 to 0x34
    input  wire [31:0] wr_data,
    output reg  [31:0] rd_data
);
    reg [31:0] data_reg [0:3];
    reg [31:0] key_reg  [0:3];
    reg        start_reg;

    wire [127:0] core_plaintext;
    wire [127:0] core_key;
    wire [127:0] core_ciphertext;
    wire         core_busy;
    wire         core_done;

    // Word mapping: index 3 is MSB [127:96], index 0 is LSB [31:0]
    assign core_plaintext = {data_reg[3], data_reg[2], data_reg[1], data_reg[0]};
    assign core_key       = {key_reg[3],  key_reg[2],  key_reg[1],  key_reg[0]};

    aes_core u_aes_core (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start_reg),
        .plaintext  (core_plaintext),
        .key        (core_key),
        .ciphertext (core_ciphertext),
        .busy       (core_busy),
        .done       (core_done)
    );

    // Register write operations
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1) begin
                data_reg[i] <= 32'h0;
                key_reg[i]  <= 32'h0;
            end
            start_reg <= 1'b0;
        end else begin
            // Clear start as soon as the core reports busy
            if (core_busy)
                start_reg <= 1'b0;

            if (sel && wr_en) begin
                case (addr[5:2])
                    4'h0: data_reg[0] <= wr_data; // 0x00: DATA0
                    4'h1: data_reg[1] <= wr_data; // 0x04: DATA1
                    4'h2: data_reg[2] <= wr_data; // 0x08: DATA2
                    4'h3: data_reg[3] <= wr_data; // 0x0C: DATA3
                    4'h4: key_reg[0]  <= wr_data; // 0x10: KEY0
                    4'h5: key_reg[1]  <= wr_data; // 0x14: KEY1
                    4'h6: key_reg[2]  <= wr_data; // 0x18: KEY2
                    4'h7: key_reg[3]  <= wr_data; // 0x1C: KEY3
                    4'h8: begin                   // 0x20: CONTROL
                        if (wr_data[0])
                            start_reg <= 1'b1;
                    end
                    default: ;
                endcase
            end
        end
    end

    // Register read operations
    always @(*) begin
        rd_data = 32'h00000000;
        if (sel && !wr_en) begin
            case (addr[5:2])
                4'h0: rd_data = data_reg[0];
                4'h1: rd_data = data_reg[1];
                4'h2: rd_data = data_reg[2];
                4'h3: rd_data = data_reg[3];
                4'h4: rd_data = key_reg[0];
                4'h5: rd_data = key_reg[1];
                4'h6: rd_data = key_reg[2];
                4'h7: rd_data = key_reg[3];
                4'h8: rd_data = {31'b0, start_reg};
                4'h9: rd_data = {30'b0, core_done, core_busy}; // 0x24: STATUS
                4'ha: rd_data = core_ciphertext[31:0];         // 0x28: OUT0
                4'hb: rd_data = core_ciphertext[63:32];        // 0x2C: OUT1
                4'hc: rd_data = core_ciphertext[95:64];        // 0x30: OUT2
                4'hd: rd_data = core_ciphertext[127:96];       // 0x34: OUT3
                default: rd_data = 32'h00000000;
            endcase
        end
    end

endmodule