// Internal efficiency case. Not an official benchmark.
// Single top module; all state is observable. No X/Z or assumed one-hot inputs.
module stress_1k_unmatched_core (
    input wire clk, input wire reset,
    input wire [63:0] enable,
    input wire [511:0] data_a, data_b,
    input wire [191:0] select_bus,
    output wire [511:0] result
);

    // Bank 0: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_0 = data_a[0 +: 8];
    wire [7:0] b_0 = data_b[0 +: 8];
    wire [7:0] prev_0 = q_63;
    wire [7:0] sum_0 = a_0 + prev_0;
    wire [7:0] diff_0 = b_0 - {prev_0[3:0], prev_0[7:4]};
    wire [7:0] rotate_0 = {sum_0[4:0], sum_0[7:5]};
    wire [7:0] left_0 = diff_0 << a_0[1:0];
    wire [7:0] right_0 = sum_0 >> b_0[1:0];
    wire [7:0] blend_0 = (rotate_0 & b_0) | (left_0 ^ right_0);
    wire [7:0] mix_0 = blend_0 ^ (a_0 & prev_0);
    reg [7:0] q_0;
    always @(posedge clk)
        if (reset) q_0 <= 8'h00;
        else if (enable[0]) q_0 <= mix_0;
    assign result[0 +: 8] = q_0;

    // Bank 1: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_1 = data_a[8 +: 8];
    wire [7:0] b_1 = data_b[8 +: 8];
    wire [7:0] prev_1 = q_0;
    wire [7:0] sum_1 = a_1 + prev_1;
    wire [7:0] diff_1 = b_1 - {prev_1[3:0], prev_1[7:4]};
    wire [7:0] rotate_1 = {sum_1[4:0], sum_1[7:5]};
    wire [7:0] left_1 = diff_1 << a_1[1:0];
    wire [7:0] right_1 = sum_1 >> b_1[1:0];
    wire [7:0] blend_1 = (rotate_1 & b_1) | (left_1 ^ right_1);
    wire [7:0] mix_1 = blend_1 ^ (a_1 & prev_1);
    reg [7:0] q_1;
    always @(posedge clk)
        if (reset) q_1 <= 8'h00;
        else if (enable[1]) q_1 <= mix_1;
    assign result[8 +: 8] = q_1;

    // Bank 2: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_2 = data_a[16 +: 8];
    wire [7:0] b_2 = data_b[16 +: 8];
    wire [7:0] prev_2 = q_1;
    wire [7:0] sum_2 = a_2 + prev_2;
    wire [7:0] diff_2 = b_2 - {prev_2[3:0], prev_2[7:4]};
    wire [7:0] rotate_2 = {sum_2[4:0], sum_2[7:5]};
    wire [7:0] left_2 = diff_2 << a_2[1:0];
    wire [7:0] right_2 = sum_2 >> b_2[1:0];
    wire [7:0] blend_2 = (rotate_2 & b_2) | (left_2 ^ right_2);
    wire [7:0] mix_2 = blend_2 ^ (a_2 & prev_2);
    reg [7:0] q_2;
    always @(posedge clk)
        if (reset) q_2 <= 8'h00;
        else if (enable[2]) q_2 <= mix_2;
    assign result[16 +: 8] = q_2;

    // Bank 3: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_3 = data_a[24 +: 8];
    wire [7:0] b_3 = data_b[24 +: 8];
    wire [7:0] prev_3 = q_2;
    wire [7:0] sum_3 = a_3 + prev_3;
    wire [7:0] diff_3 = b_3 - {prev_3[3:0], prev_3[7:4]};
    wire [7:0] rotate_3 = {sum_3[4:0], sum_3[7:5]};
    wire [7:0] left_3 = diff_3 << a_3[1:0];
    wire [7:0] right_3 = sum_3 >> b_3[1:0];
    wire [7:0] blend_3 = (rotate_3 & b_3) | (left_3 ^ right_3);
    wire [7:0] mix_3 = blend_3 ^ (a_3 & prev_3);
    reg [7:0] q_3;
    always @(posedge clk)
        if (reset) q_3 <= 8'h00;
        else if (enable[3]) q_3 <= mix_3;
    assign result[24 +: 8] = q_3;

    // Bank 4: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_4 = data_a[32 +: 8];
    wire [7:0] b_4 = data_b[32 +: 8];
    wire [7:0] prev_4 = q_3;
    wire [7:0] sum_4 = a_4 + prev_4;
    wire [7:0] diff_4 = b_4 - {prev_4[3:0], prev_4[7:4]};
    wire [7:0] rotate_4 = {sum_4[4:0], sum_4[7:5]};
    wire [7:0] left_4 = diff_4 << a_4[1:0];
    wire [7:0] right_4 = sum_4 >> b_4[1:0];
    wire [7:0] blend_4 = (rotate_4 & b_4) | (left_4 ^ right_4);
    wire [7:0] mix_4 = blend_4 ^ (a_4 & prev_4);
    reg [7:0] q_4;
    always @(posedge clk)
        if (reset) q_4 <= 8'h00;
        else if (enable[4]) q_4 <= mix_4;
    assign result[32 +: 8] = q_4;

    // Bank 5: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_5 = data_a[40 +: 8];
    wire [7:0] b_5 = data_b[40 +: 8];
    wire [7:0] prev_5 = q_4;
    wire [7:0] sum_5 = a_5 + prev_5;
    wire [7:0] diff_5 = b_5 - {prev_5[3:0], prev_5[7:4]};
    wire [7:0] rotate_5 = {sum_5[4:0], sum_5[7:5]};
    wire [7:0] left_5 = diff_5 << a_5[1:0];
    wire [7:0] right_5 = sum_5 >> b_5[1:0];
    wire [7:0] blend_5 = (rotate_5 & b_5) | (left_5 ^ right_5);
    wire [7:0] mix_5 = blend_5 ^ (a_5 & prev_5);
    reg [7:0] q_5;
    always @(posedge clk)
        if (reset) q_5 <= 8'h00;
        else if (enable[5]) q_5 <= mix_5;
    assign result[40 +: 8] = q_5;

    // Bank 6: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_6 = data_a[48 +: 8];
    wire [7:0] b_6 = data_b[48 +: 8];
    wire [7:0] prev_6 = q_5;
    wire [7:0] sum_6 = a_6 + prev_6;
    wire [7:0] diff_6 = b_6 - {prev_6[3:0], prev_6[7:4]};
    wire [7:0] rotate_6 = {sum_6[4:0], sum_6[7:5]};
    wire [7:0] left_6 = diff_6 << a_6[1:0];
    wire [7:0] right_6 = sum_6 >> b_6[1:0];
    wire [7:0] blend_6 = (rotate_6 & b_6) | (left_6 ^ right_6);
    wire [7:0] mix_6 = blend_6 ^ (a_6 & prev_6);
    reg [7:0] q_6;
    always @(posedge clk)
        if (reset) q_6 <= 8'h00;
        else if (enable[6]) q_6 <= mix_6;
    assign result[48 +: 8] = q_6;

    // Bank 7: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_7 = data_a[56 +: 8];
    wire [7:0] b_7 = data_b[56 +: 8];
    wire [7:0] prev_7 = q_6;
    wire [7:0] sum_7 = a_7 + prev_7;
    wire [7:0] diff_7 = b_7 - {prev_7[3:0], prev_7[7:4]};
    wire [7:0] rotate_7 = {sum_7[4:0], sum_7[7:5]};
    wire [7:0] left_7 = diff_7 << a_7[1:0];
    wire [7:0] right_7 = sum_7 >> b_7[1:0];
    wire [7:0] blend_7 = (rotate_7 & b_7) | (left_7 ^ right_7);
    wire [7:0] mix_7 = blend_7 ^ (a_7 & prev_7);
    reg [7:0] q_7;
    always @(posedge clk)
        if (reset) q_7 <= 8'h00;
        else if (enable[7]) q_7 <= mix_7;
    assign result[56 +: 8] = q_7;

    // Bank 8: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_8 = data_a[64 +: 8];
    wire [7:0] b_8 = data_b[64 +: 8];
    wire [7:0] prev_8 = q_7;
    wire [7:0] sum_8 = a_8 + prev_8;
    wire [7:0] diff_8 = b_8 - {prev_8[3:0], prev_8[7:4]};
    wire [7:0] rotate_8 = {sum_8[4:0], sum_8[7:5]};
    wire [7:0] left_8 = diff_8 << a_8[1:0];
    wire [7:0] right_8 = sum_8 >> b_8[1:0];
    wire [7:0] blend_8 = (rotate_8 & b_8) | (left_8 ^ right_8);
    wire [7:0] mix_8 = blend_8 ^ (a_8 & prev_8);
    reg [7:0] q_8;
    always @(posedge clk)
        if (reset) q_8 <= 8'h00;
        else if (enable[8]) q_8 <= mix_8;
    assign result[64 +: 8] = q_8;

    // Bank 9: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_9 = data_a[72 +: 8];
    wire [7:0] b_9 = data_b[72 +: 8];
    wire [7:0] prev_9 = q_8;
    wire [7:0] sum_9 = a_9 + prev_9;
    wire [7:0] diff_9 = b_9 - {prev_9[3:0], prev_9[7:4]};
    wire [7:0] rotate_9 = {sum_9[4:0], sum_9[7:5]};
    wire [7:0] left_9 = diff_9 << a_9[1:0];
    wire [7:0] right_9 = sum_9 >> b_9[1:0];
    wire [7:0] blend_9 = (rotate_9 & b_9) | (left_9 ^ right_9);
    wire [7:0] mix_9 = blend_9 ^ (a_9 & prev_9);
    reg [7:0] q_9;
    always @(posedge clk)
        if (reset) q_9 <= 8'h00;
        else if (enable[9]) q_9 <= mix_9;
    assign result[72 +: 8] = q_9;

    // Bank 10: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_10 = data_a[80 +: 8];
    wire [7:0] b_10 = data_b[80 +: 8];
    wire [7:0] prev_10 = q_9;
    wire [7:0] sum_10 = a_10 + prev_10;
    wire [7:0] diff_10 = b_10 - {prev_10[3:0], prev_10[7:4]};
    wire [7:0] rotate_10 = {sum_10[4:0], sum_10[7:5]};
    wire [7:0] left_10 = diff_10 << a_10[1:0];
    wire [7:0] right_10 = sum_10 >> b_10[1:0];
    wire [7:0] blend_10 = (rotate_10 & b_10) | (left_10 ^ right_10);
    wire [7:0] mix_10 = blend_10 ^ (a_10 & prev_10);
    reg [7:0] q_10;
    always @(posedge clk)
        if (reset) q_10 <= 8'h00;
        else if (enable[10]) q_10 <= mix_10;
    assign result[80 +: 8] = q_10;

    // Bank 11: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_11 = data_a[88 +: 8];
    wire [7:0] b_11 = data_b[88 +: 8];
    wire [7:0] prev_11 = q_10;
    wire [7:0] sum_11 = a_11 + prev_11;
    wire [7:0] diff_11 = b_11 - {prev_11[3:0], prev_11[7:4]};
    wire [7:0] rotate_11 = {sum_11[4:0], sum_11[7:5]};
    wire [7:0] left_11 = diff_11 << a_11[1:0];
    wire [7:0] right_11 = sum_11 >> b_11[1:0];
    wire [7:0] blend_11 = (rotate_11 & b_11) | (left_11 ^ right_11);
    wire [7:0] mix_11 = blend_11 ^ (a_11 & prev_11);
    reg [7:0] q_11;
    always @(posedge clk)
        if (reset) q_11 <= 8'h00;
        else if (enable[11]) q_11 <= mix_11;
    assign result[88 +: 8] = q_11;

    // Bank 12: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_12 = data_a[96 +: 8];
    wire [7:0] b_12 = data_b[96 +: 8];
    wire [7:0] prev_12 = q_11;
    wire [7:0] sum_12 = a_12 + prev_12;
    wire [7:0] diff_12 = b_12 - {prev_12[3:0], prev_12[7:4]};
    wire [7:0] rotate_12 = {sum_12[4:0], sum_12[7:5]};
    wire [7:0] left_12 = diff_12 << a_12[1:0];
    wire [7:0] right_12 = sum_12 >> b_12[1:0];
    wire [7:0] blend_12 = (rotate_12 & b_12) | (left_12 ^ right_12);
    wire [7:0] mix_12 = blend_12 ^ (a_12 & prev_12);
    reg [7:0] q_12;
    always @(posedge clk)
        if (reset) q_12 <= 8'h00;
        else if (enable[12]) q_12 <= mix_12;
    assign result[96 +: 8] = q_12;

    // Bank 13: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_13 = data_a[104 +: 8];
    wire [7:0] b_13 = data_b[104 +: 8];
    wire [7:0] prev_13 = q_12;
    wire [7:0] sum_13 = a_13 + prev_13;
    wire [7:0] diff_13 = b_13 - {prev_13[3:0], prev_13[7:4]};
    wire [7:0] rotate_13 = {sum_13[4:0], sum_13[7:5]};
    wire [7:0] left_13 = diff_13 << a_13[1:0];
    wire [7:0] right_13 = sum_13 >> b_13[1:0];
    wire [7:0] blend_13 = (rotate_13 & b_13) | (left_13 ^ right_13);
    wire [7:0] mix_13 = blend_13 ^ (a_13 & prev_13);
    reg [7:0] q_13;
    always @(posedge clk)
        if (reset) q_13 <= 8'h00;
        else if (enable[13]) q_13 <= mix_13;
    assign result[104 +: 8] = q_13;

    // Bank 14: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_14 = data_a[112 +: 8];
    wire [7:0] b_14 = data_b[112 +: 8];
    wire [7:0] prev_14 = q_13;
    wire [7:0] sum_14 = a_14 + prev_14;
    wire [7:0] diff_14 = b_14 - {prev_14[3:0], prev_14[7:4]};
    wire [7:0] rotate_14 = {sum_14[4:0], sum_14[7:5]};
    wire [7:0] left_14 = diff_14 << a_14[1:0];
    wire [7:0] right_14 = sum_14 >> b_14[1:0];
    wire [7:0] blend_14 = (rotate_14 & b_14) | (left_14 ^ right_14);
    wire [7:0] mix_14 = blend_14 ^ (a_14 & prev_14);
    reg [7:0] q_14;
    always @(posedge clk)
        if (reset) q_14 <= 8'h00;
        else if (enable[14]) q_14 <= mix_14;
    assign result[112 +: 8] = q_14;

    // Bank 15: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_15 = data_a[120 +: 8];
    wire [7:0] b_15 = data_b[120 +: 8];
    wire [7:0] prev_15 = q_14;
    wire [7:0] sum_15 = a_15 + prev_15;
    wire [7:0] diff_15 = b_15 - {prev_15[3:0], prev_15[7:4]};
    wire [7:0] rotate_15 = {sum_15[4:0], sum_15[7:5]};
    wire [7:0] left_15 = diff_15 << a_15[1:0];
    wire [7:0] right_15 = sum_15 >> b_15[1:0];
    wire [7:0] blend_15 = (rotate_15 & b_15) | (left_15 ^ right_15);
    wire [7:0] mix_15 = blend_15 ^ (a_15 & prev_15);
    reg [7:0] q_15;
    always @(posedge clk)
        if (reset) q_15 <= 8'h00;
        else if (enable[15]) q_15 <= mix_15;
    assign result[120 +: 8] = q_15;

    // Bank 16: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_16 = data_a[128 +: 8];
    wire [7:0] b_16 = data_b[128 +: 8];
    wire [7:0] prev_16 = q_15;
    wire [7:0] sum_16 = a_16 + prev_16;
    wire [7:0] diff_16 = b_16 - {prev_16[3:0], prev_16[7:4]};
    wire [7:0] rotate_16 = {sum_16[4:0], sum_16[7:5]};
    wire [7:0] left_16 = diff_16 << a_16[1:0];
    wire [7:0] right_16 = sum_16 >> b_16[1:0];
    wire [7:0] blend_16 = (rotate_16 & b_16) | (left_16 ^ right_16);
    wire [7:0] mix_16 = blend_16 ^ (a_16 & prev_16);
    reg [7:0] q_16;
    always @(posedge clk)
        if (reset) q_16 <= 8'h00;
        else if (enable[16]) q_16 <= mix_16;
    assign result[128 +: 8] = q_16;

    // Bank 17: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_17 = data_a[136 +: 8];
    wire [7:0] b_17 = data_b[136 +: 8];
    wire [7:0] prev_17 = q_16;
    wire [7:0] sum_17 = a_17 + prev_17;
    wire [7:0] diff_17 = b_17 - {prev_17[3:0], prev_17[7:4]};
    wire [7:0] rotate_17 = {sum_17[4:0], sum_17[7:5]};
    wire [7:0] left_17 = diff_17 << a_17[1:0];
    wire [7:0] right_17 = sum_17 >> b_17[1:0];
    wire [7:0] blend_17 = (rotate_17 & b_17) | (left_17 ^ right_17);
    wire [7:0] mix_17 = blend_17 ^ (a_17 & prev_17);
    reg [7:0] q_17;
    always @(posedge clk)
        if (reset) q_17 <= 8'h00;
        else if (enable[17]) q_17 <= mix_17;
    assign result[136 +: 8] = q_17;

    // Bank 18: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_18 = data_a[144 +: 8];
    wire [7:0] b_18 = data_b[144 +: 8];
    wire [7:0] prev_18 = q_17;
    wire [7:0] sum_18 = a_18 + prev_18;
    wire [7:0] diff_18 = b_18 - {prev_18[3:0], prev_18[7:4]};
    wire [7:0] rotate_18 = {sum_18[4:0], sum_18[7:5]};
    wire [7:0] left_18 = diff_18 << a_18[1:0];
    wire [7:0] right_18 = sum_18 >> b_18[1:0];
    wire [7:0] blend_18 = (rotate_18 & b_18) | (left_18 ^ right_18);
    wire [7:0] mix_18 = blend_18 ^ (a_18 & prev_18);
    reg [7:0] q_18;
    always @(posedge clk)
        if (reset) q_18 <= 8'h00;
        else if (enable[18]) q_18 <= mix_18;
    assign result[144 +: 8] = q_18;

    // Bank 19: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_19 = data_a[152 +: 8];
    wire [7:0] b_19 = data_b[152 +: 8];
    wire [7:0] prev_19 = q_18;
    wire [7:0] sum_19 = a_19 + prev_19;
    wire [7:0] diff_19 = b_19 - {prev_19[3:0], prev_19[7:4]};
    wire [7:0] rotate_19 = {sum_19[4:0], sum_19[7:5]};
    wire [7:0] left_19 = diff_19 << a_19[1:0];
    wire [7:0] right_19 = sum_19 >> b_19[1:0];
    wire [7:0] blend_19 = (rotate_19 & b_19) | (left_19 ^ right_19);
    wire [7:0] mix_19 = blend_19 ^ (a_19 & prev_19);
    reg [7:0] q_19;
    always @(posedge clk)
        if (reset) q_19 <= 8'h00;
        else if (enable[19]) q_19 <= mix_19;
    assign result[152 +: 8] = q_19;

    // Bank 20: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_20 = data_a[160 +: 8];
    wire [7:0] b_20 = data_b[160 +: 8];
    wire [7:0] prev_20 = q_19;
    wire [7:0] sum_20 = a_20 + prev_20;
    wire [7:0] diff_20 = b_20 - {prev_20[3:0], prev_20[7:4]};
    wire [7:0] rotate_20 = {sum_20[4:0], sum_20[7:5]};
    wire [7:0] left_20 = diff_20 << a_20[1:0];
    wire [7:0] right_20 = sum_20 >> b_20[1:0];
    wire [7:0] blend_20 = (rotate_20 & b_20) | (left_20 ^ right_20);
    wire [7:0] mix_20 = blend_20 ^ (a_20 & prev_20);
    reg [7:0] q_20;
    always @(posedge clk)
        if (reset) q_20 <= 8'h00;
        else if (enable[20]) q_20 <= mix_20;
    assign result[160 +: 8] = q_20;

    // Bank 21: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_21 = data_a[168 +: 8];
    wire [7:0] b_21 = data_b[168 +: 8];
    wire [7:0] prev_21 = q_20;
    wire [7:0] sum_21 = a_21 + prev_21;
    wire [7:0] diff_21 = b_21 - {prev_21[3:0], prev_21[7:4]};
    wire [7:0] rotate_21 = {sum_21[4:0], sum_21[7:5]};
    wire [7:0] left_21 = diff_21 << a_21[1:0];
    wire [7:0] right_21 = sum_21 >> b_21[1:0];
    wire [7:0] blend_21 = (rotate_21 & b_21) | (left_21 ^ right_21);
    wire [7:0] mix_21 = blend_21 ^ (a_21 & prev_21);
    reg [7:0] q_21;
    always @(posedge clk)
        if (reset) q_21 <= 8'h00;
        else if (enable[21]) q_21 <= mix_21;
    assign result[168 +: 8] = q_21;

    // Bank 22: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_22 = data_a[176 +: 8];
    wire [7:0] b_22 = data_b[176 +: 8];
    wire [7:0] prev_22 = q_21;
    wire [7:0] sum_22 = a_22 + prev_22;
    wire [7:0] diff_22 = b_22 - {prev_22[3:0], prev_22[7:4]};
    wire [7:0] rotate_22 = {sum_22[4:0], sum_22[7:5]};
    wire [7:0] left_22 = diff_22 << a_22[1:0];
    wire [7:0] right_22 = sum_22 >> b_22[1:0];
    wire [7:0] blend_22 = (rotate_22 & b_22) | (left_22 ^ right_22);
    wire [7:0] mix_22 = blend_22 ^ (a_22 & prev_22);
    reg [7:0] q_22;
    always @(posedge clk)
        if (reset) q_22 <= 8'h00;
        else if (enable[22]) q_22 <= mix_22;
    assign result[176 +: 8] = q_22;

    // Bank 23: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_23 = data_a[184 +: 8];
    wire [7:0] b_23 = data_b[184 +: 8];
    wire [7:0] prev_23 = q_22;
    wire [7:0] sum_23 = a_23 + prev_23;
    wire [7:0] diff_23 = b_23 - {prev_23[3:0], prev_23[7:4]};
    wire [7:0] rotate_23 = {sum_23[4:0], sum_23[7:5]};
    wire [7:0] left_23 = diff_23 << a_23[1:0];
    wire [7:0] right_23 = sum_23 >> b_23[1:0];
    wire [7:0] blend_23 = (rotate_23 & b_23) | (left_23 ^ right_23);
    wire [7:0] mix_23 = blend_23 ^ (a_23 & prev_23);
    reg [7:0] q_23;
    always @(posedge clk)
        if (reset) q_23 <= 8'h00;
        else if (enable[23]) q_23 <= mix_23;
    assign result[184 +: 8] = q_23;

    // Bank 24: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_24 = data_a[192 +: 8];
    wire [7:0] b_24 = data_b[192 +: 8];
    wire [7:0] prev_24 = q_23;
    wire [7:0] sum_24 = a_24 + prev_24;
    wire [7:0] diff_24 = b_24 - {prev_24[3:0], prev_24[7:4]};
    wire [7:0] rotate_24 = {sum_24[4:0], sum_24[7:5]};
    wire [7:0] left_24 = diff_24 << a_24[1:0];
    wire [7:0] right_24 = sum_24 >> b_24[1:0];
    wire [7:0] blend_24 = (rotate_24 & b_24) | (left_24 ^ right_24);
    wire [7:0] mix_24 = blend_24 ^ (a_24 & prev_24);
    reg [7:0] q_24;
    always @(posedge clk)
        if (reset) q_24 <= 8'h00;
        else if (enable[24]) q_24 <= mix_24;
    assign result[192 +: 8] = q_24;

    // Bank 25: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_25 = data_a[200 +: 8];
    wire [7:0] b_25 = data_b[200 +: 8];
    wire [7:0] prev_25 = q_24;
    wire [7:0] sum_25 = a_25 + prev_25;
    wire [7:0] diff_25 = b_25 - {prev_25[3:0], prev_25[7:4]};
    wire [7:0] rotate_25 = {sum_25[4:0], sum_25[7:5]};
    wire [7:0] left_25 = diff_25 << a_25[1:0];
    wire [7:0] right_25 = sum_25 >> b_25[1:0];
    wire [7:0] blend_25 = (rotate_25 & b_25) | (left_25 ^ right_25);
    wire [7:0] mix_25 = blend_25 ^ (a_25 & prev_25);
    reg [7:0] q_25;
    always @(posedge clk)
        if (reset) q_25 <= 8'h00;
        else if (enable[25]) q_25 <= mix_25;
    assign result[200 +: 8] = q_25;

    // Bank 26: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_26 = data_a[208 +: 8];
    wire [7:0] b_26 = data_b[208 +: 8];
    wire [7:0] prev_26 = q_25;
    wire [7:0] sum_26 = a_26 + prev_26;
    wire [7:0] diff_26 = b_26 - {prev_26[3:0], prev_26[7:4]};
    wire [7:0] rotate_26 = {sum_26[4:0], sum_26[7:5]};
    wire [7:0] left_26 = diff_26 << a_26[1:0];
    wire [7:0] right_26 = sum_26 >> b_26[1:0];
    wire [7:0] blend_26 = (rotate_26 & b_26) | (left_26 ^ right_26);
    wire [7:0] mix_26 = blend_26 ^ (a_26 & prev_26);
    reg [7:0] q_26;
    always @(posedge clk)
        if (reset) q_26 <= 8'h00;
        else if (enable[26]) q_26 <= mix_26;
    assign result[208 +: 8] = q_26;

    // Bank 27: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_27 = data_a[216 +: 8];
    wire [7:0] b_27 = data_b[216 +: 8];
    wire [7:0] prev_27 = q_26;
    wire [7:0] sum_27 = a_27 + prev_27;
    wire [7:0] diff_27 = b_27 - {prev_27[3:0], prev_27[7:4]};
    wire [7:0] rotate_27 = {sum_27[4:0], sum_27[7:5]};
    wire [7:0] left_27 = diff_27 << a_27[1:0];
    wire [7:0] right_27 = sum_27 >> b_27[1:0];
    wire [7:0] blend_27 = (rotate_27 & b_27) | (left_27 ^ right_27);
    wire [7:0] mix_27 = blend_27 ^ (a_27 & prev_27);
    reg [7:0] q_27;
    always @(posedge clk)
        if (reset) q_27 <= 8'h00;
        else if (enable[27]) q_27 <= mix_27;
    assign result[216 +: 8] = q_27;

    // Bank 28: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_28 = data_a[224 +: 8];
    wire [7:0] b_28 = data_b[224 +: 8];
    wire [7:0] prev_28 = q_27;
    wire [7:0] sum_28 = a_28 + prev_28;
    wire [7:0] diff_28 = b_28 - {prev_28[3:0], prev_28[7:4]};
    wire [7:0] rotate_28 = {sum_28[4:0], sum_28[7:5]};
    wire [7:0] left_28 = diff_28 << a_28[1:0];
    wire [7:0] right_28 = sum_28 >> b_28[1:0];
    wire [7:0] blend_28 = (rotate_28 & b_28) | (left_28 ^ right_28);
    wire [7:0] mix_28 = blend_28 ^ (a_28 & prev_28);
    reg [7:0] q_28;
    always @(posedge clk)
        if (reset) q_28 <= 8'h00;
        else if (enable[28]) q_28 <= mix_28;
    assign result[224 +: 8] = q_28;

    // Bank 29: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_29 = data_a[232 +: 8];
    wire [7:0] b_29 = data_b[232 +: 8];
    wire [7:0] prev_29 = q_28;
    wire [7:0] sum_29 = a_29 + prev_29;
    wire [7:0] diff_29 = b_29 - {prev_29[3:0], prev_29[7:4]};
    wire [7:0] rotate_29 = {sum_29[4:0], sum_29[7:5]};
    wire [7:0] left_29 = diff_29 << a_29[1:0];
    wire [7:0] right_29 = sum_29 >> b_29[1:0];
    wire [7:0] blend_29 = (rotate_29 & b_29) | (left_29 ^ right_29);
    wire [7:0] mix_29 = blend_29 ^ (a_29 & prev_29);
    reg [7:0] q_29;
    always @(posedge clk)
        if (reset) q_29 <= 8'h00;
        else if (enable[29]) q_29 <= mix_29;
    assign result[232 +: 8] = q_29;

    // Bank 30: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_30 = data_a[240 +: 8];
    wire [7:0] b_30 = data_b[240 +: 8];
    wire [7:0] prev_30 = q_29;
    wire [7:0] sum_30 = a_30 + prev_30;
    wire [7:0] diff_30 = b_30 - {prev_30[3:0], prev_30[7:4]};
    wire [7:0] rotate_30 = {sum_30[4:0], sum_30[7:5]};
    wire [7:0] left_30 = diff_30 << a_30[1:0];
    wire [7:0] right_30 = sum_30 >> b_30[1:0];
    wire [7:0] blend_30 = (rotate_30 & b_30) | (left_30 ^ right_30);
    wire [7:0] mix_30 = blend_30 ^ (a_30 & prev_30);
    reg [7:0] q_30;
    always @(posedge clk)
        if (reset) q_30 <= 8'h00;
        else if (enable[30]) q_30 <= mix_30;
    assign result[240 +: 8] = q_30;

    // Bank 31: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_31 = data_a[248 +: 8];
    wire [7:0] b_31 = data_b[248 +: 8];
    wire [7:0] prev_31 = q_30;
    wire [7:0] sum_31 = a_31 + prev_31;
    wire [7:0] diff_31 = b_31 - {prev_31[3:0], prev_31[7:4]};
    wire [7:0] rotate_31 = {sum_31[4:0], sum_31[7:5]};
    wire [7:0] left_31 = diff_31 << a_31[1:0];
    wire [7:0] right_31 = sum_31 >> b_31[1:0];
    wire [7:0] blend_31 = (rotate_31 & b_31) | (left_31 ^ right_31);
    wire [7:0] mix_31 = blend_31 ^ (a_31 & prev_31);
    reg [7:0] q_31;
    always @(posedge clk)
        if (reset) q_31 <= 8'h00;
        else if (enable[31]) q_31 <= mix_31;
    assign result[248 +: 8] = q_31;

    // Bank 32: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_32 = data_a[256 +: 8];
    wire [7:0] b_32 = data_b[256 +: 8];
    wire [7:0] prev_32 = q_31;
    wire [7:0] sum_32 = a_32 + prev_32;
    wire [7:0] diff_32 = b_32 - {prev_32[3:0], prev_32[7:4]};
    wire [7:0] rotate_32 = {sum_32[4:0], sum_32[7:5]};
    wire [7:0] left_32 = diff_32 << a_32[1:0];
    wire [7:0] right_32 = sum_32 >> b_32[1:0];
    wire [7:0] blend_32 = (rotate_32 & b_32) | (left_32 ^ right_32);
    wire [7:0] mix_32 = blend_32 ^ (a_32 & prev_32);
    reg [7:0] q_32;
    always @(posedge clk)
        if (reset) q_32 <= 8'h00;
        else if (enable[32]) q_32 <= mix_32;
    assign result[256 +: 8] = q_32;

    // Bank 33: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_33 = data_a[264 +: 8];
    wire [7:0] b_33 = data_b[264 +: 8];
    wire [7:0] prev_33 = q_32;
    wire [7:0] sum_33 = a_33 + prev_33;
    wire [7:0] diff_33 = b_33 - {prev_33[3:0], prev_33[7:4]};
    wire [7:0] rotate_33 = {sum_33[4:0], sum_33[7:5]};
    wire [7:0] left_33 = diff_33 << a_33[1:0];
    wire [7:0] right_33 = sum_33 >> b_33[1:0];
    wire [7:0] blend_33 = (rotate_33 & b_33) | (left_33 ^ right_33);
    wire [7:0] mix_33 = blend_33 ^ (a_33 & prev_33);
    reg [7:0] q_33;
    always @(posedge clk)
        if (reset) q_33 <= 8'h00;
        else if (enable[33]) q_33 <= mix_33;
    assign result[264 +: 8] = q_33;

    // Bank 34: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_34 = data_a[272 +: 8];
    wire [7:0] b_34 = data_b[272 +: 8];
    wire [7:0] prev_34 = q_33;
    wire [7:0] sum_34 = a_34 + prev_34;
    wire [7:0] diff_34 = b_34 - {prev_34[3:0], prev_34[7:4]};
    wire [7:0] rotate_34 = {sum_34[4:0], sum_34[7:5]};
    wire [7:0] left_34 = diff_34 << a_34[1:0];
    wire [7:0] right_34 = sum_34 >> b_34[1:0];
    wire [7:0] blend_34 = (rotate_34 & b_34) | (left_34 ^ right_34);
    wire [7:0] mix_34 = blend_34 ^ (a_34 & prev_34);
    reg [7:0] q_34;
    always @(posedge clk)
        if (reset) q_34 <= 8'h00;
        else if (enable[34]) q_34 <= mix_34;
    assign result[272 +: 8] = q_34;

    // Bank 35: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_35 = data_a[280 +: 8];
    wire [7:0] b_35 = data_b[280 +: 8];
    wire [7:0] prev_35 = q_34;
    wire [7:0] sum_35 = a_35 + prev_35;
    wire [7:0] diff_35 = b_35 - {prev_35[3:0], prev_35[7:4]};
    wire [7:0] rotate_35 = {sum_35[4:0], sum_35[7:5]};
    wire [7:0] left_35 = diff_35 << a_35[1:0];
    wire [7:0] right_35 = sum_35 >> b_35[1:0];
    wire [7:0] blend_35 = (rotate_35 & b_35) | (left_35 ^ right_35);
    wire [7:0] mix_35 = blend_35 ^ (a_35 & prev_35);
    reg [7:0] q_35;
    always @(posedge clk)
        if (reset) q_35 <= 8'h00;
        else if (enable[35]) q_35 <= mix_35;
    assign result[280 +: 8] = q_35;

    // Bank 36: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_36 = data_a[288 +: 8];
    wire [7:0] b_36 = data_b[288 +: 8];
    wire [7:0] prev_36 = q_35;
    wire [7:0] sum_36 = a_36 + prev_36;
    wire [7:0] diff_36 = b_36 - {prev_36[3:0], prev_36[7:4]};
    wire [7:0] rotate_36 = {sum_36[4:0], sum_36[7:5]};
    wire [7:0] left_36 = diff_36 << a_36[1:0];
    wire [7:0] right_36 = sum_36 >> b_36[1:0];
    wire [7:0] blend_36 = (rotate_36 & b_36) | (left_36 ^ right_36);
    wire [7:0] mix_36 = blend_36 ^ (a_36 & prev_36);
    reg [7:0] q_36;
    always @(posedge clk)
        if (reset) q_36 <= 8'h00;
        else if (enable[36]) q_36 <= mix_36;
    assign result[288 +: 8] = q_36;

    // Bank 37: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_37 = data_a[296 +: 8];
    wire [7:0] b_37 = data_b[296 +: 8];
    wire [7:0] prev_37 = q_36;
    wire [7:0] sum_37 = a_37 + prev_37;
    wire [7:0] diff_37 = b_37 - {prev_37[3:0], prev_37[7:4]};
    wire [7:0] rotate_37 = {sum_37[4:0], sum_37[7:5]};
    wire [7:0] left_37 = diff_37 << a_37[1:0];
    wire [7:0] right_37 = sum_37 >> b_37[1:0];
    wire [7:0] blend_37 = (rotate_37 & b_37) | (left_37 ^ right_37);
    wire [7:0] mix_37 = blend_37 ^ (a_37 & prev_37);
    reg [7:0] q_37;
    always @(posedge clk)
        if (reset) q_37 <= 8'h00;
        else if (enable[37]) q_37 <= mix_37;
    assign result[296 +: 8] = q_37;

    // Bank 38: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_38 = data_a[304 +: 8];
    wire [7:0] b_38 = data_b[304 +: 8];
    wire [7:0] prev_38 = q_37;
    wire [7:0] sum_38 = a_38 + prev_38;
    wire [7:0] diff_38 = b_38 - {prev_38[3:0], prev_38[7:4]};
    wire [7:0] rotate_38 = {sum_38[4:0], sum_38[7:5]};
    wire [7:0] left_38 = diff_38 << a_38[1:0];
    wire [7:0] right_38 = sum_38 >> b_38[1:0];
    wire [7:0] blend_38 = (rotate_38 & b_38) | (left_38 ^ right_38);
    wire [7:0] mix_38 = blend_38 ^ (a_38 & prev_38);
    reg [7:0] q_38;
    always @(posedge clk)
        if (reset) q_38 <= 8'h00;
        else if (enable[38]) q_38 <= mix_38;
    assign result[304 +: 8] = q_38;

    // Bank 39: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_39 = data_a[312 +: 8];
    wire [7:0] b_39 = data_b[312 +: 8];
    wire [7:0] prev_39 = q_38;
    wire [7:0] sum_39 = a_39 + prev_39;
    wire [7:0] diff_39 = b_39 - {prev_39[3:0], prev_39[7:4]};
    wire [7:0] rotate_39 = {sum_39[4:0], sum_39[7:5]};
    wire [7:0] left_39 = diff_39 << a_39[1:0];
    wire [7:0] right_39 = sum_39 >> b_39[1:0];
    wire [7:0] blend_39 = (rotate_39 & b_39) | (left_39 ^ right_39);
    wire [7:0] mix_39 = blend_39 ^ (a_39 & prev_39);
    reg [7:0] q_39;
    always @(posedge clk)
        if (reset) q_39 <= 8'h00;
        else if (enable[39]) q_39 <= mix_39;
    assign result[312 +: 8] = q_39;

    // Bank 40: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_40 = data_a[320 +: 8];
    wire [7:0] b_40 = data_b[320 +: 8];
    wire [7:0] prev_40 = q_39;
    wire [7:0] sum_40 = a_40 + prev_40;
    wire [7:0] diff_40 = b_40 - {prev_40[3:0], prev_40[7:4]};
    wire [7:0] rotate_40 = {sum_40[4:0], sum_40[7:5]};
    wire [7:0] left_40 = diff_40 << a_40[1:0];
    wire [7:0] right_40 = sum_40 >> b_40[1:0];
    wire [7:0] blend_40 = (rotate_40 & b_40) | (left_40 ^ right_40);
    wire [7:0] mix_40 = blend_40 ^ (a_40 & prev_40);
    reg [7:0] q_40;
    always @(posedge clk)
        if (reset) q_40 <= 8'h00;
        else if (enable[40]) q_40 <= mix_40;
    assign result[320 +: 8] = q_40;

    // Bank 41: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_41 = data_a[328 +: 8];
    wire [7:0] b_41 = data_b[328 +: 8];
    wire [7:0] prev_41 = q_40;
    wire [7:0] sum_41 = a_41 + prev_41;
    wire [7:0] diff_41 = b_41 - {prev_41[3:0], prev_41[7:4]};
    wire [7:0] rotate_41 = {sum_41[4:0], sum_41[7:5]};
    wire [7:0] left_41 = diff_41 << a_41[1:0];
    wire [7:0] right_41 = sum_41 >> b_41[1:0];
    wire [7:0] blend_41 = (rotate_41 & b_41) | (left_41 ^ right_41);
    wire [7:0] mix_41 = blend_41 ^ (a_41 & prev_41);
    reg [7:0] q_41;
    always @(posedge clk)
        if (reset) q_41 <= 8'h00;
        else if (enable[41]) q_41 <= mix_41;
    assign result[328 +: 8] = q_41;

    // Bank 42: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_42 = data_a[336 +: 8];
    wire [7:0] b_42 = data_b[336 +: 8];
    wire [7:0] prev_42 = q_41;
    wire [7:0] sum_42 = a_42 + prev_42;
    wire [7:0] diff_42 = b_42 - {prev_42[3:0], prev_42[7:4]};
    wire [7:0] rotate_42 = {sum_42[4:0], sum_42[7:5]};
    wire [7:0] left_42 = diff_42 << a_42[1:0];
    wire [7:0] right_42 = sum_42 >> b_42[1:0];
    wire [7:0] blend_42 = (rotate_42 & b_42) | (left_42 ^ right_42);
    wire [7:0] mix_42 = blend_42 ^ (a_42 & prev_42);
    reg [7:0] q_42;
    always @(posedge clk)
        if (reset) q_42 <= 8'h00;
        else if (enable[42]) q_42 <= mix_42;
    assign result[336 +: 8] = q_42;

    // Bank 43: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_43 = data_a[344 +: 8];
    wire [7:0] b_43 = data_b[344 +: 8];
    wire [7:0] prev_43 = q_42;
    wire [7:0] sum_43 = a_43 + prev_43;
    wire [7:0] diff_43 = b_43 - {prev_43[3:0], prev_43[7:4]};
    wire [7:0] rotate_43 = {sum_43[4:0], sum_43[7:5]};
    wire [7:0] left_43 = diff_43 << a_43[1:0];
    wire [7:0] right_43 = sum_43 >> b_43[1:0];
    wire [7:0] blend_43 = (rotate_43 & b_43) | (left_43 ^ right_43);
    wire [7:0] mix_43 = blend_43 ^ (a_43 & prev_43);
    reg [7:0] q_43;
    always @(posedge clk)
        if (reset) q_43 <= 8'h00;
        else if (enable[43]) q_43 <= mix_43;
    assign result[344 +: 8] = q_43;

    // Bank 44: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_44 = data_a[352 +: 8];
    wire [7:0] b_44 = data_b[352 +: 8];
    wire [7:0] prev_44 = q_43;
    wire [7:0] sum_44 = a_44 + prev_44;
    wire [7:0] diff_44 = b_44 - {prev_44[3:0], prev_44[7:4]};
    wire [7:0] rotate_44 = {sum_44[4:0], sum_44[7:5]};
    wire [7:0] left_44 = diff_44 << a_44[1:0];
    wire [7:0] right_44 = sum_44 >> b_44[1:0];
    wire [7:0] blend_44 = (rotate_44 & b_44) | (left_44 ^ right_44);
    wire [7:0] mix_44 = blend_44 ^ (a_44 & prev_44);
    reg [7:0] q_44;
    always @(posedge clk)
        if (reset) q_44 <= 8'h00;
        else if (enable[44]) q_44 <= mix_44;
    assign result[352 +: 8] = q_44;

    // Bank 45: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_45 = data_a[360 +: 8];
    wire [7:0] b_45 = data_b[360 +: 8];
    wire [7:0] prev_45 = q_44;
    wire [7:0] sum_45 = a_45 + prev_45;
    wire [7:0] diff_45 = b_45 - {prev_45[3:0], prev_45[7:4]};
    wire [7:0] rotate_45 = {sum_45[4:0], sum_45[7:5]};
    wire [7:0] left_45 = diff_45 << a_45[1:0];
    wire [7:0] right_45 = sum_45 >> b_45[1:0];
    wire [7:0] blend_45 = (rotate_45 & b_45) | (left_45 ^ right_45);
    wire [7:0] mix_45 = blend_45 ^ (a_45 & prev_45);
    reg [7:0] q_45;
    always @(posedge clk)
        if (reset) q_45 <= 8'h00;
        else if (enable[45]) q_45 <= mix_45;
    assign result[360 +: 8] = q_45;

    // Bank 46: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_46 = data_a[368 +: 8];
    wire [7:0] b_46 = data_b[368 +: 8];
    wire [7:0] prev_46 = q_45;
    wire [7:0] sum_46 = a_46 + prev_46;
    wire [7:0] diff_46 = b_46 - {prev_46[3:0], prev_46[7:4]};
    wire [7:0] rotate_46 = {sum_46[4:0], sum_46[7:5]};
    wire [7:0] left_46 = diff_46 << a_46[1:0];
    wire [7:0] right_46 = sum_46 >> b_46[1:0];
    wire [7:0] blend_46 = (rotate_46 & b_46) | (left_46 ^ right_46);
    wire [7:0] mix_46 = blend_46 ^ (a_46 & prev_46);
    reg [7:0] q_46;
    always @(posedge clk)
        if (reset) q_46 <= 8'h00;
        else if (enable[46]) q_46 <= mix_46;
    assign result[368 +: 8] = q_46;

    // Bank 47: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_47 = data_a[376 +: 8];
    wire [7:0] b_47 = data_b[376 +: 8];
    wire [7:0] prev_47 = q_46;
    wire [7:0] sum_47 = a_47 + prev_47;
    wire [7:0] diff_47 = b_47 - {prev_47[3:0], prev_47[7:4]};
    wire [7:0] rotate_47 = {sum_47[4:0], sum_47[7:5]};
    wire [7:0] left_47 = diff_47 << a_47[1:0];
    wire [7:0] right_47 = sum_47 >> b_47[1:0];
    wire [7:0] blend_47 = (rotate_47 & b_47) | (left_47 ^ right_47);
    wire [7:0] mix_47 = blend_47 ^ (a_47 & prev_47);
    reg [7:0] q_47;
    always @(posedge clk)
        if (reset) q_47 <= 8'h00;
        else if (enable[47]) q_47 <= mix_47;
    assign result[376 +: 8] = q_47;

    // Bank 48: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_48 = data_a[384 +: 8];
    wire [7:0] b_48 = data_b[384 +: 8];
    wire [7:0] prev_48 = q_47;
    wire [7:0] sum_48 = a_48 + prev_48;
    wire [7:0] diff_48 = b_48 - {prev_48[3:0], prev_48[7:4]};
    wire [7:0] rotate_48 = {sum_48[4:0], sum_48[7:5]};
    wire [7:0] left_48 = diff_48 << a_48[1:0];
    wire [7:0] right_48 = sum_48 >> b_48[1:0];
    wire [7:0] blend_48 = (rotate_48 & b_48) | (left_48 ^ right_48);
    wire [7:0] mix_48 = blend_48 ^ (a_48 & prev_48);
    reg [7:0] q_48;
    always @(posedge clk)
        if (reset) q_48 <= 8'h00;
        else if (enable[48]) q_48 <= mix_48;
    assign result[384 +: 8] = q_48;

    // Bank 49: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_49 = data_a[392 +: 8];
    wire [7:0] b_49 = data_b[392 +: 8];
    wire [7:0] prev_49 = q_48;
    wire [7:0] sum_49 = a_49 + prev_49;
    wire [7:0] diff_49 = b_49 - {prev_49[3:0], prev_49[7:4]};
    wire [7:0] rotate_49 = {sum_49[4:0], sum_49[7:5]};
    wire [7:0] left_49 = diff_49 << a_49[1:0];
    wire [7:0] right_49 = sum_49 >> b_49[1:0];
    wire [7:0] blend_49 = (rotate_49 & b_49) | (left_49 ^ right_49);
    wire [7:0] mix_49 = blend_49 ^ (a_49 & prev_49);
    reg [7:0] q_49;
    always @(posedge clk)
        if (reset) q_49 <= 8'h00;
        else if (enable[49]) q_49 <= mix_49;
    assign result[392 +: 8] = q_49;

    // Bank 50: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_50 = data_a[400 +: 8];
    wire [7:0] b_50 = data_b[400 +: 8];
    wire [7:0] prev_50 = q_49;
    wire [7:0] sum_50 = a_50 + prev_50;
    wire [7:0] diff_50 = b_50 - {prev_50[3:0], prev_50[7:4]};
    wire [7:0] rotate_50 = {sum_50[4:0], sum_50[7:5]};
    wire [7:0] left_50 = diff_50 << a_50[1:0];
    wire [7:0] right_50 = sum_50 >> b_50[1:0];
    wire [7:0] blend_50 = (rotate_50 & b_50) | (left_50 ^ right_50);
    wire [7:0] mix_50 = blend_50 ^ (a_50 & prev_50);
    reg [7:0] q_50;
    always @(posedge clk)
        if (reset) q_50 <= 8'h00;
        else if (enable[50]) q_50 <= mix_50;
    assign result[400 +: 8] = q_50;

    // Bank 51: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_51 = data_a[408 +: 8];
    wire [7:0] b_51 = data_b[408 +: 8];
    wire [7:0] prev_51 = q_50;
    wire [7:0] sum_51 = a_51 + prev_51;
    wire [7:0] diff_51 = b_51 - {prev_51[3:0], prev_51[7:4]};
    wire [7:0] rotate_51 = {sum_51[4:0], sum_51[7:5]};
    wire [7:0] left_51 = diff_51 << a_51[1:0];
    wire [7:0] right_51 = sum_51 >> b_51[1:0];
    wire [7:0] blend_51 = (rotate_51 & b_51) | (left_51 ^ right_51);
    wire [7:0] mix_51 = blend_51 ^ (a_51 & prev_51);
    reg [7:0] q_51;
    always @(posedge clk)
        if (reset) q_51 <= 8'h00;
        else if (enable[51]) q_51 <= mix_51;
    assign result[408 +: 8] = q_51;

    // Bank 52: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_52 = data_a[416 +: 8];
    wire [7:0] b_52 = data_b[416 +: 8];
    wire [7:0] prev_52 = q_51;
    wire [7:0] sum_52 = a_52 + prev_52;
    wire [7:0] diff_52 = b_52 - {prev_52[3:0], prev_52[7:4]};
    wire [7:0] rotate_52 = {sum_52[4:0], sum_52[7:5]};
    wire [7:0] left_52 = diff_52 << a_52[1:0];
    wire [7:0] right_52 = sum_52 >> b_52[1:0];
    wire [7:0] blend_52 = (rotate_52 & b_52) | (left_52 ^ right_52);
    wire [7:0] mix_52 = blend_52 ^ (a_52 & prev_52);
    reg [7:0] q_52;
    always @(posedge clk)
        if (reset) q_52 <= 8'h00;
        else if (enable[52]) q_52 <= mix_52;
    assign result[416 +: 8] = q_52;

    // Bank 53: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_53 = data_a[424 +: 8];
    wire [7:0] b_53 = data_b[424 +: 8];
    wire [7:0] prev_53 = q_52;
    wire [7:0] sum_53 = a_53 + prev_53;
    wire [7:0] diff_53 = b_53 - {prev_53[3:0], prev_53[7:4]};
    wire [7:0] rotate_53 = {sum_53[4:0], sum_53[7:5]};
    wire [7:0] left_53 = diff_53 << a_53[1:0];
    wire [7:0] right_53 = sum_53 >> b_53[1:0];
    wire [7:0] blend_53 = (rotate_53 & b_53) | (left_53 ^ right_53);
    wire [7:0] mix_53 = blend_53 ^ (a_53 & prev_53);
    reg [7:0] q_53;
    always @(posedge clk)
        if (reset) q_53 <= 8'h00;
        else if (enable[53]) q_53 <= mix_53;
    assign result[424 +: 8] = q_53;

    // Bank 54: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_54 = data_a[432 +: 8];
    wire [7:0] b_54 = data_b[432 +: 8];
    wire [7:0] prev_54 = q_53;
    wire [7:0] sum_54 = a_54 + prev_54;
    wire [7:0] diff_54 = b_54 - {prev_54[3:0], prev_54[7:4]};
    wire [7:0] rotate_54 = {sum_54[4:0], sum_54[7:5]};
    wire [7:0] left_54 = diff_54 << a_54[1:0];
    wire [7:0] right_54 = sum_54 >> b_54[1:0];
    wire [7:0] blend_54 = (rotate_54 & b_54) | (left_54 ^ right_54);
    wire [7:0] mix_54 = blend_54 ^ (a_54 & prev_54);
    reg [7:0] q_54;
    always @(posedge clk)
        if (reset) q_54 <= 8'h00;
        else if (enable[54]) q_54 <= mix_54;
    assign result[432 +: 8] = q_54;

    // Bank 55: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_55 = data_a[440 +: 8];
    wire [7:0] b_55 = data_b[440 +: 8];
    wire [7:0] prev_55 = q_54;
    wire [7:0] sum_55 = a_55 + prev_55;
    wire [7:0] diff_55 = b_55 - {prev_55[3:0], prev_55[7:4]};
    wire [7:0] rotate_55 = {sum_55[4:0], sum_55[7:5]};
    wire [7:0] left_55 = diff_55 << a_55[1:0];
    wire [7:0] right_55 = sum_55 >> b_55[1:0];
    wire [7:0] blend_55 = (rotate_55 & b_55) | (left_55 ^ right_55);
    wire [7:0] mix_55 = blend_55 ^ (a_55 & prev_55);
    reg [7:0] q_55;
    always @(posedge clk)
        if (reset) q_55 <= 8'h00;
        else if (enable[55]) q_55 <= mix_55;
    assign result[440 +: 8] = q_55;

    // Bank 56: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_56 = data_a[448 +: 8];
    wire [7:0] b_56 = data_b[448 +: 8];
    wire [7:0] prev_56 = q_55;
    wire [7:0] sum_56 = a_56 + prev_56;
    wire [7:0] diff_56 = b_56 - {prev_56[3:0], prev_56[7:4]};
    wire [7:0] rotate_56 = {sum_56[4:0], sum_56[7:5]};
    wire [7:0] left_56 = diff_56 << a_56[1:0];
    wire [7:0] right_56 = sum_56 >> b_56[1:0];
    wire [7:0] blend_56 = (rotate_56 & b_56) | (left_56 ^ right_56);
    wire [7:0] mix_56 = blend_56 ^ (a_56 & prev_56);
    reg [7:0] q_56;
    always @(posedge clk)
        if (reset) q_56 <= 8'h00;
        else if (enable[56]) q_56 <= mix_56;
    assign result[448 +: 8] = q_56;

    // Bank 57: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_57 = data_a[456 +: 8];
    wire [7:0] b_57 = data_b[456 +: 8];
    wire [7:0] prev_57 = q_56;
    wire [7:0] sum_57 = a_57 + prev_57;
    wire [7:0] diff_57 = b_57 - {prev_57[3:0], prev_57[7:4]};
    wire [7:0] rotate_57 = {sum_57[4:0], sum_57[7:5]};
    wire [7:0] left_57 = diff_57 << a_57[1:0];
    wire [7:0] right_57 = sum_57 >> b_57[1:0];
    wire [7:0] blend_57 = (rotate_57 & b_57) | (left_57 ^ right_57);
    wire [7:0] mix_57 = blend_57 ^ (a_57 & prev_57);
    reg [7:0] q_57;
    always @(posedge clk)
        if (reset) q_57 <= 8'h00;
        else if (enable[57]) q_57 <= mix_57;
    assign result[456 +: 8] = q_57;

    // Bank 58: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_58 = data_a[464 +: 8];
    wire [7:0] b_58 = data_b[464 +: 8];
    wire [7:0] prev_58 = q_57;
    wire [7:0] sum_58 = a_58 + prev_58;
    wire [7:0] diff_58 = b_58 - {prev_58[3:0], prev_58[7:4]};
    wire [7:0] rotate_58 = {sum_58[4:0], sum_58[7:5]};
    wire [7:0] left_58 = diff_58 << a_58[1:0];
    wire [7:0] right_58 = sum_58 >> b_58[1:0];
    wire [7:0] blend_58 = (rotate_58 & b_58) | (left_58 ^ right_58);
    wire [7:0] mix_58 = blend_58 ^ (a_58 & prev_58);
    reg [7:0] q_58;
    always @(posedge clk)
        if (reset) q_58 <= 8'h00;
        else if (enable[58]) q_58 <= mix_58;
    assign result[464 +: 8] = q_58;

    // Bank 59: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_59 = data_a[472 +: 8];
    wire [7:0] b_59 = data_b[472 +: 8];
    wire [7:0] prev_59 = q_58;
    wire [7:0] sum_59 = a_59 + prev_59;
    wire [7:0] diff_59 = b_59 - {prev_59[3:0], prev_59[7:4]};
    wire [7:0] rotate_59 = {sum_59[4:0], sum_59[7:5]};
    wire [7:0] left_59 = diff_59 << a_59[1:0];
    wire [7:0] right_59 = sum_59 >> b_59[1:0];
    wire [7:0] blend_59 = (rotate_59 & b_59) | (left_59 ^ right_59);
    wire [7:0] mix_59 = blend_59 ^ (a_59 & prev_59);
    reg [7:0] q_59;
    always @(posedge clk)
        if (reset) q_59 <= 8'h00;
        else if (enable[59]) q_59 <= mix_59;
    assign result[472 +: 8] = q_59;

    // Bank 60: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_60 = data_a[480 +: 8];
    wire [7:0] b_60 = data_b[480 +: 8];
    wire [7:0] prev_60 = q_59;
    wire [7:0] sum_60 = a_60 + prev_60;
    wire [7:0] diff_60 = b_60 - {prev_60[3:0], prev_60[7:4]};
    wire [7:0] rotate_60 = {sum_60[4:0], sum_60[7:5]};
    wire [7:0] left_60 = diff_60 << a_60[1:0];
    wire [7:0] right_60 = sum_60 >> b_60[1:0];
    wire [7:0] blend_60 = (rotate_60 & b_60) | (left_60 ^ right_60);
    wire [7:0] mix_60 = blend_60 ^ (a_60 & prev_60);
    reg [7:0] q_60;
    always @(posedge clk)
        if (reset) q_60 <= 8'h00;
        else if (enable[60]) q_60 <= mix_60;
    assign result[480 +: 8] = q_60;

    // Bank 61: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_61 = data_a[488 +: 8];
    wire [7:0] b_61 = data_b[488 +: 8];
    wire [7:0] prev_61 = q_60;
    wire [7:0] sum_61 = a_61 + prev_61;
    wire [7:0] diff_61 = b_61 - {prev_61[3:0], prev_61[7:4]};
    wire [7:0] rotate_61 = {sum_61[4:0], sum_61[7:5]};
    wire [7:0] left_61 = diff_61 << a_61[1:0];
    wire [7:0] right_61 = sum_61 >> b_61[1:0];
    wire [7:0] blend_61 = (rotate_61 & b_61) | (left_61 ^ right_61);
    wire [7:0] mix_61 = blend_61 ^ (a_61 & prev_61);
    reg [7:0] q_61;
    always @(posedge clk)
        if (reset) q_61 <= 8'h00;
        else if (enable[61]) q_61 <= mix_61;
    assign result[488 +: 8] = q_61;

    // Bank 62: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_62 = data_a[496 +: 8];
    wire [7:0] b_62 = data_b[496 +: 8];
    wire [7:0] prev_62 = q_61;
    wire [7:0] sum_62 = a_62 + prev_62;
    wire [7:0] diff_62 = b_62 - {prev_62[3:0], prev_62[7:4]};
    wire [7:0] rotate_62 = {sum_62[4:0], sum_62[7:5]};
    wire [7:0] left_62 = diff_62 << a_62[1:0];
    wire [7:0] right_62 = sum_62 >> b_62[1:0];
    wire [7:0] blend_62 = (rotate_62 & b_62) | (left_62 ^ right_62);
    wire [7:0] mix_62 = blend_62 ^ (a_62 & prev_62);
    reg [7:0] q_62;
    always @(posedge clk)
        if (reset) q_62 <= 8'h00;
        else if (enable[62]) q_62 <= mix_62;
    assign result[496 +: 8] = q_62;

    // Bank 63: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_63 = data_a[504 +: 8];
    wire [7:0] b_63 = data_b[504 +: 8];
    wire [7:0] prev_63 = q_62;
    wire [7:0] sum_63 = a_63 + prev_63;
    wire [7:0] diff_63 = b_63 - {prev_63[3:0], prev_63[7:4]};
    wire [7:0] rotate_63 = {sum_63[4:0], sum_63[7:5]};
    wire [7:0] left_63 = diff_63 << a_63[1:0];
    wire [7:0] right_63 = sum_63 >> b_63[1:0];
    wire [7:0] blend_63 = (rotate_63 & b_63) | (left_63 ^ right_63);
    wire [7:0] mix_63 = blend_63 ^ (a_63 & prev_63);
    reg [7:0] q_63;
    always @(posedge clk)
        if (reset) q_63 <= 8'h00;
        else if (enable[63]) q_63 <= mix_63;
    assign result[504 +: 8] = q_63;

endmodule

module stress_1k_unmatched (
input wire clk, reset,
input wire [127:0] enable,
input wire [1023:0] data_a, data_b,
input wire [383:0] select_bus,
output wire [1023:0] result
);
stress_1k_unmatched_core u0 (.clk(clk), .reset(reset), .enable(enable[0 +: 64]), .data_a(data_a[0 +: 512]), .data_b(data_b[0 +: 512]), .select_bus(select_bus[0 +: 192]), .result(result[0 +: 512]));
stress_1k_unmatched_core u1 (.clk(clk), .reset(reset), .enable(enable[64 +: 64]), .data_a(data_a[512 +: 512]), .data_b(data_b[512 +: 512]), .select_bus(select_bus[192 +: 192]), .result(result[512 +: 512]));
endmodule
