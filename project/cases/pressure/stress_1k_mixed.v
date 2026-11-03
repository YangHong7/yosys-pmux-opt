// Internal efficiency case. Not an official benchmark.
// Single top module; all state is observable. No X/Z or assumed one-hot inputs.
module stress_1k_mixed_core (
    input wire clk, input wire reset,
    input wire [47:0] enable,
    input wire [383:0] data_a, data_b,
    input wire [143:0] select_bus,
    output wire [383:0] result,
    output wire [383:0] auxiliary
);

    // Bank 0: one-cycle coupling through previous bank, no combinational loop.
    wire [7:0] a_0 = data_a[0 +: 8];
    wire [7:0] b_0 = data_b[0 +: 8];
    wire [7:0] prev_0 = q_47;
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

    reg [7:0] mux_a_0, mux_b_0;
    always @* begin
        mux_a_0 = a_0 ^ prev_0;
        mux_b_0 = b_0 + prev_0;
        case (select_bus[0 +: 3])
            3'd0: begin mux_a_0 = a_0; mux_b_0 = b_0; end
            3'd1: begin mux_a_0 = b_0; mux_b_0 = a_0; end
            3'd2: begin mux_a_0 = prev_0; mux_b_0 = sum_0; end
            3'd3: begin mux_a_0 = sum_0; mux_b_0 = prev_0; end
            3'd4: begin mux_a_0 = diff_0; mux_b_0 = blend_0; end
            3'd5: begin mux_a_0 = blend_0; mux_b_0 = diff_0; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_0;
    always @(posedge clk)
        if (reset) mux_q_0 <= 16'h0000;
        else if (enable[0]) mux_q_0 <= {mux_b_0, mux_a_0};

    reg [7:0] table_0;
    always @* begin
        case (a_0[4:0] ^ prev_0[4:0])
            5'd0: table_0 = 8'h60;
            5'd1: table_0 = 8'h5d;
            5'd2: table_0 = 8'h4d;
            5'd3: table_0 = 8'h70;
            5'd4: table_0 = 8'h60;
            5'd5: table_0 = 8'h5d;
            5'd6: table_0 = 8'h9b;
            5'd7: table_0 = 8'h26;
            5'd8: table_0 = 8'h60;
            5'd9: table_0 = 8'h5d;
            5'd10: table_0 = 8'h4d;
            5'd11: table_0 = 8'h70;
            5'd12: table_0 = 8'h4d;
            5'd13: table_0 = 8'h5d;
            5'd14: table_0 = 8'h9b;
            5'd15: table_0 = 8'h8b;
            5'd16: table_0 = 8'h3e;
            5'd17: table_0 = 8'h83;
            5'd18: table_0 = 8'h93;
            5'd19: table_0 = 8'h2e;
            5'd20: table_0 = 8'h3e;
            5'd21: table_0 = 8'h83;
            5'd22: table_0 = 8'h45;
            5'd23: table_0 = 8'h78;
            5'd24: table_0 = 8'h3e;
            5'd25: table_0 = 8'h83;
            5'd26: table_0 = 8'h93;
            5'd27: table_0 = 8'h2e;
            5'd28: table_0 = 8'h93;
            5'd29: table_0 = 8'h83;
            5'd30: table_0 = 8'h45;
            5'd31: table_0 = 8'h55;
            default: table_0 = 8'h00;
        endcase
    end

    wire [7:0] compare_0;
    assign compare_0[0] = (a_0 == 8'ha0);
    assign compare_0[1] = (a_0 == 8'ha1);
    assign compare_0[2] = (a_0 == 8'ha2);
    assign compare_0[3] = (a_0 == 8'ha3);
    assign compare_0[4] = (a_0 == 8'ha4);
    assign compare_0[5] = (a_0 == 8'ha5);
    assign compare_0[6] = (a_0 == 8'ha6);
    assign compare_0[7] = (a_0 == 8'ha7);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_0 =
        a_0[0] ? b_0 :
        a_0[1] ? prev_0 :
        a_0[2] ? sum_0 :
        a_0[3] ? diff_0 : blend_0;
    reg [7:0] auxiliary_0;
    always @(posedge clk)
        if (reset) auxiliary_0 <= 8'h00;
        else if (enable[0])
            auxiliary_0 <= table_0 ^ compare_0 ^ priority_0
                ^ mux_q_0[7:0] ^ mux_q_0[15:8];
    assign auxiliary[0 +: 8] = auxiliary_0;

    reg [7:0] mux_a_1, mux_b_1;
    always @* begin
        mux_a_1 = a_1 ^ prev_1;
        mux_b_1 = b_1 + prev_1;
        case (select_bus[3 +: 3])
            3'd0: begin mux_a_1 = a_1; mux_b_1 = b_1; end
            3'd1: begin mux_a_1 = b_1; mux_b_1 = a_1; end
            3'd2: begin mux_a_1 = prev_1; mux_b_1 = sum_1; end
            3'd3: begin mux_a_1 = sum_1; mux_b_1 = prev_1; end
            3'd4: begin mux_a_1 = diff_1; mux_b_1 = left_1; end
            3'd5: begin mux_a_1 = blend_1; mux_b_1 = right_1; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_1;
    always @(posedge clk)
        if (reset) mux_q_1 <= 16'h0000;
        else if (enable[1]) mux_q_1 <= {mux_b_1, mux_a_1};

    reg [7:0] table_1;
    always @* begin
        case (a_1[4:0] ^ prev_1[4:0])
            5'd0: table_1 = 8'h83;
            5'd1: table_1 = 8'ha9;
            5'd2: table_1 = 8'h2b;
            5'd3: table_1 = 8'h36;
            5'd4: table_1 = 8'h2f;
            5'd5: table_1 = 8'hfe;
            5'd6: table_1 = 8'h89;
            5'd7: table_1 = 8'hf5;
            5'd8: table_1 = 8'h51;
            5'd9: table_1 = 8'h2e;
            5'd10: table_1 = 8'hce;
            5'd11: table_1 = 8'hf3;
            5'd12: table_1 = 8'h3f;
            5'd13: table_1 = 8'h31;
            5'd14: table_1 = 8'h21;
            5'd15: table_1 = 8'h00;
            5'd16: table_1 = 8'ha9;
            5'd17: table_1 = 8'h02;
            5'd18: table_1 = 8'h37;
            5'd19: table_1 = 8'h5d;
            5'd20: table_1 = 8'h80;
            5'd21: table_1 = 8'h05;
            5'd22: table_1 = 8'h33;
            5'd23: table_1 = 8'h25;
            5'd24: table_1 = 8'hd2;
            5'd25: table_1 = 8'h60;
            5'd26: table_1 = 8'h86;
            5'd27: table_1 = 8'ha6;
            5'd28: table_1 = 8'hab;
            5'd29: table_1 = 8'h63;
            5'd30: table_1 = 8'hcf;
            5'd31: table_1 = 8'hc7;
            default: table_1 = 8'h00;
        endcase
    end

    wire [7:0] compare_1;
    assign compare_1[0] = (a_1 == 8'h00);
    assign compare_1[1] = (a_1 == 8'h0f);
    assign compare_1[2] = (a_1 == 8'h33);
    assign compare_1[3] = (a_1 == 8'h55);
    assign compare_1[4] = (a_1 == 8'h66);
    assign compare_1[5] = (a_1 == 8'h99);
    assign compare_1[6] = (a_1 == 8'hc3);
    assign compare_1[7] = (a_1 == 8'hf0);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_1 =
        a_1[0] ? b_1 :
        a_1[1] ? prev_1 :
        a_1[2] ? sum_1 :
        a_1[3] ? diff_1 : blend_1;
    reg [7:0] auxiliary_1;
    always @(posedge clk)
        if (reset) auxiliary_1 <= 8'h00;
        else if (enable[1])
            auxiliary_1 <= table_1 ^ compare_1 ^ priority_1
                ^ mux_q_1[7:0] ^ mux_q_1[15:8];
    assign auxiliary[8 +: 8] = auxiliary_1;
    assign auxiliary[16 +: 8] = q_2 ^ q_1;
    assign auxiliary[24 +: 8] = q_3 ^ q_2;
    assign auxiliary[32 +: 8] = q_4 ^ q_3;
    assign auxiliary[40 +: 8] = q_5 ^ q_4;

    reg [7:0] mux_a_6, mux_b_6;
    always @* begin
        mux_a_6 = a_6 ^ prev_6;
        mux_b_6 = b_6 + prev_6;
        case (select_bus[18 +: 3])
            3'd0: begin mux_a_6 = a_6; mux_b_6 = b_6; end
            3'd1: begin mux_a_6 = b_6; mux_b_6 = a_6; end
            3'd2: begin mux_a_6 = prev_6; mux_b_6 = sum_6; end
            3'd3: begin mux_a_6 = sum_6; mux_b_6 = prev_6; end
            3'd4: begin mux_a_6 = diff_6; mux_b_6 = blend_6; end
            3'd5: begin mux_a_6 = blend_6; mux_b_6 = diff_6; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_6;
    always @(posedge clk)
        if (reset) mux_q_6 <= 16'h0000;
        else if (enable[6]) mux_q_6 <= {mux_b_6, mux_a_6};

    reg [7:0] table_6;
    always @* begin
        case (a_6[4:0] ^ prev_6[4:0])
            5'd0: table_6 = 8'h60;
            5'd1: table_6 = 8'h5d;
            5'd2: table_6 = 8'h4d;
            5'd3: table_6 = 8'h70;
            5'd4: table_6 = 8'h60;
            5'd5: table_6 = 8'h5d;
            5'd6: table_6 = 8'h9b;
            5'd7: table_6 = 8'h26;
            5'd8: table_6 = 8'h60;
            5'd9: table_6 = 8'h5d;
            5'd10: table_6 = 8'h4d;
            5'd11: table_6 = 8'h70;
            5'd12: table_6 = 8'h4d;
            5'd13: table_6 = 8'h5d;
            5'd14: table_6 = 8'h9b;
            5'd15: table_6 = 8'h8b;
            5'd16: table_6 = 8'h3e;
            5'd17: table_6 = 8'h83;
            5'd18: table_6 = 8'h93;
            5'd19: table_6 = 8'h2e;
            5'd20: table_6 = 8'h3e;
            5'd21: table_6 = 8'h83;
            5'd22: table_6 = 8'h45;
            5'd23: table_6 = 8'h78;
            5'd24: table_6 = 8'h3e;
            5'd25: table_6 = 8'h83;
            5'd26: table_6 = 8'h93;
            5'd27: table_6 = 8'h2e;
            5'd28: table_6 = 8'h93;
            5'd29: table_6 = 8'h83;
            5'd30: table_6 = 8'h45;
            5'd31: table_6 = 8'h55;
            default: table_6 = 8'h00;
        endcase
    end

    wire [7:0] compare_6;
    assign compare_6[0] = (a_6 == 8'ha0);
    assign compare_6[1] = (a_6 == 8'ha1);
    assign compare_6[2] = (a_6 == 8'ha2);
    assign compare_6[3] = (a_6 == 8'ha3);
    assign compare_6[4] = (a_6 == 8'ha4);
    assign compare_6[5] = (a_6 == 8'ha5);
    assign compare_6[6] = (a_6 == 8'ha6);
    assign compare_6[7] = (a_6 == 8'ha7);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_6 =
        a_6[0] ? b_6 :
        a_6[1] ? prev_6 :
        a_6[2] ? sum_6 :
        a_6[3] ? diff_6 : blend_6;
    reg [7:0] auxiliary_6;
    always @(posedge clk)
        if (reset) auxiliary_6 <= 8'h00;
        else if (enable[6])
            auxiliary_6 <= table_6 ^ compare_6 ^ priority_6
                ^ mux_q_6[7:0] ^ mux_q_6[15:8];
    assign auxiliary[48 +: 8] = auxiliary_6;

    reg [7:0] mux_a_7, mux_b_7;
    always @* begin
        mux_a_7 = a_7 ^ prev_7;
        mux_b_7 = b_7 + prev_7;
        case (select_bus[21 +: 3])
            3'd0: begin mux_a_7 = a_7; mux_b_7 = b_7; end
            3'd1: begin mux_a_7 = b_7; mux_b_7 = a_7; end
            3'd2: begin mux_a_7 = prev_7; mux_b_7 = sum_7; end
            3'd3: begin mux_a_7 = sum_7; mux_b_7 = prev_7; end
            3'd4: begin mux_a_7 = diff_7; mux_b_7 = left_7; end
            3'd5: begin mux_a_7 = blend_7; mux_b_7 = right_7; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_7;
    always @(posedge clk)
        if (reset) mux_q_7 <= 16'h0000;
        else if (enable[7]) mux_q_7 <= {mux_b_7, mux_a_7};

    reg [7:0] table_7;
    always @* begin
        case (a_7[4:0] ^ prev_7[4:0])
            5'd0: table_7 = 8'h77;
            5'd1: table_7 = 8'h50;
            5'd2: table_7 = 8'h0c;
            5'd3: table_7 = 8'hb2;
            5'd4: table_7 = 8'h40;
            5'd5: table_7 = 8'h51;
            5'd6: table_7 = 8'h6a;
            5'd7: table_7 = 8'h9f;
            5'd8: table_7 = 8'h3a;
            5'd9: table_7 = 8'hd9;
            5'd10: table_7 = 8'h38;
            5'd11: table_7 = 8'h65;
            5'd12: table_7 = 8'h38;
            5'd13: table_7 = 8'hcc;
            5'd14: table_7 = 8'h84;
            5'd15: table_7 = 8'h06;
            5'd16: table_7 = 8'h7e;
            5'd17: table_7 = 8'he3;
            5'd18: table_7 = 8'h7d;
            5'd19: table_7 = 8'h4a;
            5'd20: table_7 = 8'h9d;
            5'd21: table_7 = 8'h0e;
            5'd22: table_7 = 8'h4e;
            5'd23: table_7 = 8'h20;
            5'd24: table_7 = 8'h54;
            5'd25: table_7 = 8'hd2;
            5'd26: table_7 = 8'h02;
            5'd27: table_7 = 8'hfc;
            5'd28: table_7 = 8'h6f;
            5'd29: table_7 = 8'hab;
            5'd30: table_7 = 8'h60;
            5'd31: table_7 = 8'h38;
            default: table_7 = 8'h00;
        endcase
    end

    wire [7:0] compare_7;
    assign compare_7[0] = (a_7 == 8'h00);
    assign compare_7[1] = (a_7 == 8'h0f);
    assign compare_7[2] = (a_7 == 8'h33);
    assign compare_7[3] = (a_7 == 8'h55);
    assign compare_7[4] = (a_7 == 8'h66);
    assign compare_7[5] = (a_7 == 8'h99);
    assign compare_7[6] = (a_7 == 8'hc3);
    assign compare_7[7] = (a_7 == 8'hf0);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_7 =
        a_7[0] ? b_7 :
        a_7[1] ? prev_7 :
        a_7[2] ? sum_7 :
        a_7[3] ? diff_7 : blend_7;
    reg [7:0] auxiliary_7;
    always @(posedge clk)
        if (reset) auxiliary_7 <= 8'h00;
        else if (enable[7])
            auxiliary_7 <= table_7 ^ compare_7 ^ priority_7
                ^ mux_q_7[7:0] ^ mux_q_7[15:8];
    assign auxiliary[56 +: 8] = auxiliary_7;
    assign auxiliary[64 +: 8] = q_8 ^ q_7;
    assign auxiliary[72 +: 8] = q_9 ^ q_8;
    assign auxiliary[80 +: 8] = q_10 ^ q_9;
    assign auxiliary[88 +: 8] = q_11 ^ q_10;

    reg [7:0] mux_a_12, mux_b_12;
    always @* begin
        mux_a_12 = a_12 ^ prev_12;
        mux_b_12 = b_12 + prev_12;
        case (select_bus[36 +: 3])
            3'd0: begin mux_a_12 = a_12; mux_b_12 = b_12; end
            3'd1: begin mux_a_12 = b_12; mux_b_12 = a_12; end
            3'd2: begin mux_a_12 = prev_12; mux_b_12 = sum_12; end
            3'd3: begin mux_a_12 = sum_12; mux_b_12 = prev_12; end
            3'd4: begin mux_a_12 = diff_12; mux_b_12 = blend_12; end
            3'd5: begin mux_a_12 = blend_12; mux_b_12 = diff_12; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_12;
    always @(posedge clk)
        if (reset) mux_q_12 <= 16'h0000;
        else if (enable[12]) mux_q_12 <= {mux_b_12, mux_a_12};

    reg [7:0] table_12;
    always @* begin
        case (a_12[4:0] ^ prev_12[4:0])
            5'd0: table_12 = 8'h60;
            5'd1: table_12 = 8'h5d;
            5'd2: table_12 = 8'h4d;
            5'd3: table_12 = 8'h70;
            5'd4: table_12 = 8'h60;
            5'd5: table_12 = 8'h5d;
            5'd6: table_12 = 8'h9b;
            5'd7: table_12 = 8'h26;
            5'd8: table_12 = 8'h60;
            5'd9: table_12 = 8'h5d;
            5'd10: table_12 = 8'h4d;
            5'd11: table_12 = 8'h70;
            5'd12: table_12 = 8'h4d;
            5'd13: table_12 = 8'h5d;
            5'd14: table_12 = 8'h9b;
            5'd15: table_12 = 8'h8b;
            5'd16: table_12 = 8'h3e;
            5'd17: table_12 = 8'h83;
            5'd18: table_12 = 8'h93;
            5'd19: table_12 = 8'h2e;
            5'd20: table_12 = 8'h3e;
            5'd21: table_12 = 8'h83;
            5'd22: table_12 = 8'h45;
            5'd23: table_12 = 8'h78;
            5'd24: table_12 = 8'h3e;
            5'd25: table_12 = 8'h83;
            5'd26: table_12 = 8'h93;
            5'd27: table_12 = 8'h2e;
            5'd28: table_12 = 8'h93;
            5'd29: table_12 = 8'h83;
            5'd30: table_12 = 8'h45;
            5'd31: table_12 = 8'h55;
            default: table_12 = 8'h00;
        endcase
    end

    wire [7:0] compare_12;
    assign compare_12[0] = (a_12 == 8'ha0);
    assign compare_12[1] = (a_12 == 8'ha1);
    assign compare_12[2] = (a_12 == 8'ha2);
    assign compare_12[3] = (a_12 == 8'ha3);
    assign compare_12[4] = (a_12 == 8'ha4);
    assign compare_12[5] = (a_12 == 8'ha5);
    assign compare_12[6] = (a_12 == 8'ha6);
    assign compare_12[7] = (a_12 == 8'ha7);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_12 =
        a_12[0] ? b_12 :
        a_12[1] ? prev_12 :
        a_12[2] ? sum_12 :
        a_12[3] ? diff_12 : blend_12;
    reg [7:0] auxiliary_12;
    always @(posedge clk)
        if (reset) auxiliary_12 <= 8'h00;
        else if (enable[12])
            auxiliary_12 <= table_12 ^ compare_12 ^ priority_12
                ^ mux_q_12[7:0] ^ mux_q_12[15:8];
    assign auxiliary[96 +: 8] = auxiliary_12;

    reg [7:0] mux_a_13, mux_b_13;
    always @* begin
        mux_a_13 = a_13 ^ prev_13;
        mux_b_13 = b_13 + prev_13;
        case (select_bus[39 +: 3])
            3'd0: begin mux_a_13 = a_13; mux_b_13 = b_13; end
            3'd1: begin mux_a_13 = b_13; mux_b_13 = a_13; end
            3'd2: begin mux_a_13 = prev_13; mux_b_13 = sum_13; end
            3'd3: begin mux_a_13 = sum_13; mux_b_13 = prev_13; end
            3'd4: begin mux_a_13 = diff_13; mux_b_13 = left_13; end
            3'd5: begin mux_a_13 = blend_13; mux_b_13 = right_13; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_13;
    always @(posedge clk)
        if (reset) mux_q_13 <= 16'h0000;
        else if (enable[13]) mux_q_13 <= {mux_b_13, mux_a_13};

    reg [7:0] table_13;
    always @* begin
        case (a_13[4:0] ^ prev_13[4:0])
            5'd0: table_13 = 8'h6b;
            5'd1: table_13 = 8'hf8;
            5'd2: table_13 = 8'hec;
            5'd3: table_13 = 8'h2d;
            5'd4: table_13 = 8'h52;
            5'd5: table_13 = 8'ha4;
            5'd6: table_13 = 8'h4b;
            5'd7: table_13 = 8'h49;
            5'd8: table_13 = 8'h22;
            5'd9: table_13 = 8'h83;
            5'd10: table_13 = 8'ha2;
            5'd11: table_13 = 8'hd7;
            5'd12: table_13 = 8'h31;
            5'd13: table_13 = 8'h67;
            5'd14: table_13 = 8'he7;
            5'd15: table_13 = 8'h0c;
            5'd16: table_13 = 8'h53;
            5'd17: table_13 = 8'hc4;
            5'd18: table_13 = 8'hc3;
            5'd19: table_13 = 8'h37;
            5'd20: table_13 = 8'hba;
            5'd21: table_13 = 8'h18;
            5'd22: table_13 = 8'h69;
            5'd23: table_13 = 8'h1b;
            5'd24: table_13 = 8'hd6;
            5'd25: table_13 = 8'h44;
            5'd26: table_13 = 8'h7e;
            5'd27: table_13 = 8'h51;
            5'd28: table_13 = 8'h34;
            5'd29: table_13 = 8'hf2;
            5'd30: table_13 = 8'hf1;
            5'd31: table_13 = 8'ha9;
            default: table_13 = 8'h00;
        endcase
    end

    wire [7:0] compare_13;
    assign compare_13[0] = (a_13 == 8'h00);
    assign compare_13[1] = (a_13 == 8'h0f);
    assign compare_13[2] = (a_13 == 8'h33);
    assign compare_13[3] = (a_13 == 8'h55);
    assign compare_13[4] = (a_13 == 8'h66);
    assign compare_13[5] = (a_13 == 8'h99);
    assign compare_13[6] = (a_13 == 8'hc3);
    assign compare_13[7] = (a_13 == 8'hf0);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_13 =
        a_13[0] ? b_13 :
        a_13[1] ? prev_13 :
        a_13[2] ? sum_13 :
        a_13[3] ? diff_13 : blend_13;
    reg [7:0] auxiliary_13;
    always @(posedge clk)
        if (reset) auxiliary_13 <= 8'h00;
        else if (enable[13])
            auxiliary_13 <= table_13 ^ compare_13 ^ priority_13
                ^ mux_q_13[7:0] ^ mux_q_13[15:8];
    assign auxiliary[104 +: 8] = auxiliary_13;
    assign auxiliary[112 +: 8] = q_14 ^ q_13;
    assign auxiliary[120 +: 8] = q_15 ^ q_14;
    assign auxiliary[128 +: 8] = q_16 ^ q_15;
    assign auxiliary[136 +: 8] = q_17 ^ q_16;

    reg [7:0] mux_a_18, mux_b_18;
    always @* begin
        mux_a_18 = a_18 ^ prev_18;
        mux_b_18 = b_18 + prev_18;
        case (select_bus[54 +: 3])
            3'd0: begin mux_a_18 = a_18; mux_b_18 = b_18; end
            3'd1: begin mux_a_18 = b_18; mux_b_18 = a_18; end
            3'd2: begin mux_a_18 = prev_18; mux_b_18 = sum_18; end
            3'd3: begin mux_a_18 = sum_18; mux_b_18 = prev_18; end
            3'd4: begin mux_a_18 = diff_18; mux_b_18 = blend_18; end
            3'd5: begin mux_a_18 = blend_18; mux_b_18 = diff_18; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_18;
    always @(posedge clk)
        if (reset) mux_q_18 <= 16'h0000;
        else if (enable[18]) mux_q_18 <= {mux_b_18, mux_a_18};

    reg [7:0] table_18;
    always @* begin
        case (a_18[4:0] ^ prev_18[4:0])
            5'd0: table_18 = 8'h60;
            5'd1: table_18 = 8'h5d;
            5'd2: table_18 = 8'h4d;
            5'd3: table_18 = 8'h70;
            5'd4: table_18 = 8'h60;
            5'd5: table_18 = 8'h5d;
            5'd6: table_18 = 8'h9b;
            5'd7: table_18 = 8'h26;
            5'd8: table_18 = 8'h60;
            5'd9: table_18 = 8'h5d;
            5'd10: table_18 = 8'h4d;
            5'd11: table_18 = 8'h70;
            5'd12: table_18 = 8'h4d;
            5'd13: table_18 = 8'h5d;
            5'd14: table_18 = 8'h9b;
            5'd15: table_18 = 8'h8b;
            5'd16: table_18 = 8'h3e;
            5'd17: table_18 = 8'h83;
            5'd18: table_18 = 8'h93;
            5'd19: table_18 = 8'h2e;
            5'd20: table_18 = 8'h3e;
            5'd21: table_18 = 8'h83;
            5'd22: table_18 = 8'h45;
            5'd23: table_18 = 8'h78;
            5'd24: table_18 = 8'h3e;
            5'd25: table_18 = 8'h83;
            5'd26: table_18 = 8'h93;
            5'd27: table_18 = 8'h2e;
            5'd28: table_18 = 8'h93;
            5'd29: table_18 = 8'h83;
            5'd30: table_18 = 8'h45;
            5'd31: table_18 = 8'h55;
            default: table_18 = 8'h00;
        endcase
    end

    wire [7:0] compare_18;
    assign compare_18[0] = (a_18 == 8'ha0);
    assign compare_18[1] = (a_18 == 8'ha1);
    assign compare_18[2] = (a_18 == 8'ha2);
    assign compare_18[3] = (a_18 == 8'ha3);
    assign compare_18[4] = (a_18 == 8'ha4);
    assign compare_18[5] = (a_18 == 8'ha5);
    assign compare_18[6] = (a_18 == 8'ha6);
    assign compare_18[7] = (a_18 == 8'ha7);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_18 =
        a_18[0] ? b_18 :
        a_18[1] ? prev_18 :
        a_18[2] ? sum_18 :
        a_18[3] ? diff_18 : blend_18;
    reg [7:0] auxiliary_18;
    always @(posedge clk)
        if (reset) auxiliary_18 <= 8'h00;
        else if (enable[18])
            auxiliary_18 <= table_18 ^ compare_18 ^ priority_18
                ^ mux_q_18[7:0] ^ mux_q_18[15:8];
    assign auxiliary[144 +: 8] = auxiliary_18;

    reg [7:0] mux_a_19, mux_b_19;
    always @* begin
        mux_a_19 = a_19 ^ prev_19;
        mux_b_19 = b_19 + prev_19;
        case (select_bus[57 +: 3])
            3'd0: begin mux_a_19 = a_19; mux_b_19 = b_19; end
            3'd1: begin mux_a_19 = b_19; mux_b_19 = a_19; end
            3'd2: begin mux_a_19 = prev_19; mux_b_19 = sum_19; end
            3'd3: begin mux_a_19 = sum_19; mux_b_19 = prev_19; end
            3'd4: begin mux_a_19 = diff_19; mux_b_19 = left_19; end
            3'd5: begin mux_a_19 = blend_19; mux_b_19 = right_19; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_19;
    always @(posedge clk)
        if (reset) mux_q_19 <= 16'h0000;
        else if (enable[19]) mux_q_19 <= {mux_b_19, mux_a_19};

    reg [7:0] table_19;
    always @* begin
        case (a_19[4:0] ^ prev_19[4:0])
            5'd0: table_19 = 8'h60;
            5'd1: table_19 = 8'ha0;
            5'd2: table_19 = 8'hcc;
            5'd3: table_19 = 8'ha9;
            5'd4: table_19 = 8'h64;
            5'd5: table_19 = 8'hf7;
            5'd6: table_19 = 8'h2d;
            5'd7: table_19 = 8'hf4;
            5'd8: table_19 = 8'h0a;
            5'd9: table_19 = 8'h2e;
            5'd10: table_19 = 8'h0b;
            5'd11: table_19 = 8'h48;
            5'd12: table_19 = 8'h2a;
            5'd13: table_19 = 8'h01;
            5'd14: table_19 = 8'h4a;
            5'd15: table_19 = 8'h12;
            5'd16: table_19 = 8'h28;
            5'd17: table_19 = 8'ha4;
            5'd18: table_19 = 8'h08;
            5'd19: table_19 = 8'h24;
            5'd20: table_19 = 8'hd7;
            5'd21: table_19 = 8'h21;
            5'd22: table_19 = 8'h84;
            5'd23: table_19 = 8'h16;
            5'd24: table_19 = 8'h58;
            5'd25: table_19 = 8'hb6;
            5'd26: table_19 = 8'hfa;
            5'd27: table_19 = 8'ha6;
            5'd28: table_19 = 8'hf9;
            5'd29: table_19 = 8'h3a;
            5'd30: table_19 = 8'h83;
            5'd31: table_19 = 8'h1a;
            default: table_19 = 8'h00;
        endcase
    end

    wire [7:0] compare_19;
    assign compare_19[0] = (a_19 == 8'h00);
    assign compare_19[1] = (a_19 == 8'h0f);
    assign compare_19[2] = (a_19 == 8'h33);
    assign compare_19[3] = (a_19 == 8'h55);
    assign compare_19[4] = (a_19 == 8'h66);
    assign compare_19[5] = (a_19 == 8'h99);
    assign compare_19[6] = (a_19 == 8'hc3);
    assign compare_19[7] = (a_19 == 8'hf0);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_19 =
        a_19[0] ? b_19 :
        a_19[1] ? prev_19 :
        a_19[2] ? sum_19 :
        a_19[3] ? diff_19 : blend_19;
    reg [7:0] auxiliary_19;
    always @(posedge clk)
        if (reset) auxiliary_19 <= 8'h00;
        else if (enable[19])
            auxiliary_19 <= table_19 ^ compare_19 ^ priority_19
                ^ mux_q_19[7:0] ^ mux_q_19[15:8];
    assign auxiliary[152 +: 8] = auxiliary_19;
    assign auxiliary[160 +: 8] = q_20 ^ q_19;
    assign auxiliary[168 +: 8] = q_21 ^ q_20;
    assign auxiliary[176 +: 8] = q_22 ^ q_21;
    assign auxiliary[184 +: 8] = q_23 ^ q_22;

    reg [7:0] mux_a_24, mux_b_24;
    always @* begin
        mux_a_24 = a_24 ^ prev_24;
        mux_b_24 = b_24 + prev_24;
        case (select_bus[72 +: 3])
            3'd0: begin mux_a_24 = a_24; mux_b_24 = b_24; end
            3'd1: begin mux_a_24 = b_24; mux_b_24 = a_24; end
            3'd2: begin mux_a_24 = prev_24; mux_b_24 = sum_24; end
            3'd3: begin mux_a_24 = sum_24; mux_b_24 = prev_24; end
            3'd4: begin mux_a_24 = diff_24; mux_b_24 = blend_24; end
            3'd5: begin mux_a_24 = blend_24; mux_b_24 = diff_24; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_24;
    always @(posedge clk)
        if (reset) mux_q_24 <= 16'h0000;
        else if (enable[24]) mux_q_24 <= {mux_b_24, mux_a_24};

    reg [7:0] table_24;
    always @* begin
        case (a_24[4:0] ^ prev_24[4:0])
            5'd0: table_24 = 8'h60;
            5'd1: table_24 = 8'h5d;
            5'd2: table_24 = 8'h4d;
            5'd3: table_24 = 8'h70;
            5'd4: table_24 = 8'h60;
            5'd5: table_24 = 8'h5d;
            5'd6: table_24 = 8'h9b;
            5'd7: table_24 = 8'h26;
            5'd8: table_24 = 8'h60;
            5'd9: table_24 = 8'h5d;
            5'd10: table_24 = 8'h4d;
            5'd11: table_24 = 8'h70;
            5'd12: table_24 = 8'h4d;
            5'd13: table_24 = 8'h5d;
            5'd14: table_24 = 8'h9b;
            5'd15: table_24 = 8'h8b;
            5'd16: table_24 = 8'h3e;
            5'd17: table_24 = 8'h83;
            5'd18: table_24 = 8'h93;
            5'd19: table_24 = 8'h2e;
            5'd20: table_24 = 8'h3e;
            5'd21: table_24 = 8'h83;
            5'd22: table_24 = 8'h45;
            5'd23: table_24 = 8'h78;
            5'd24: table_24 = 8'h3e;
            5'd25: table_24 = 8'h83;
            5'd26: table_24 = 8'h93;
            5'd27: table_24 = 8'h2e;
            5'd28: table_24 = 8'h93;
            5'd29: table_24 = 8'h83;
            5'd30: table_24 = 8'h45;
            5'd31: table_24 = 8'h55;
            default: table_24 = 8'h00;
        endcase
    end

    wire [7:0] compare_24;
    assign compare_24[0] = (a_24 == 8'ha0);
    assign compare_24[1] = (a_24 == 8'ha1);
    assign compare_24[2] = (a_24 == 8'ha2);
    assign compare_24[3] = (a_24 == 8'ha3);
    assign compare_24[4] = (a_24 == 8'ha4);
    assign compare_24[5] = (a_24 == 8'ha5);
    assign compare_24[6] = (a_24 == 8'ha6);
    assign compare_24[7] = (a_24 == 8'ha7);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_24 =
        a_24[0] ? b_24 :
        a_24[1] ? prev_24 :
        a_24[2] ? sum_24 :
        a_24[3] ? diff_24 : blend_24;
    reg [7:0] auxiliary_24;
    always @(posedge clk)
        if (reset) auxiliary_24 <= 8'h00;
        else if (enable[24])
            auxiliary_24 <= table_24 ^ compare_24 ^ priority_24
                ^ mux_q_24[7:0] ^ mux_q_24[15:8];
    assign auxiliary[192 +: 8] = auxiliary_24;

    reg [7:0] mux_a_25, mux_b_25;
    always @* begin
        mux_a_25 = a_25 ^ prev_25;
        mux_b_25 = b_25 + prev_25;
        case (select_bus[75 +: 3])
            3'd0: begin mux_a_25 = a_25; mux_b_25 = b_25; end
            3'd1: begin mux_a_25 = b_25; mux_b_25 = a_25; end
            3'd2: begin mux_a_25 = prev_25; mux_b_25 = sum_25; end
            3'd3: begin mux_a_25 = sum_25; mux_b_25 = prev_25; end
            3'd4: begin mux_a_25 = diff_25; mux_b_25 = left_25; end
            3'd5: begin mux_a_25 = blend_25; mux_b_25 = right_25; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_25;
    always @(posedge clk)
        if (reset) mux_q_25 <= 16'h0000;
        else if (enable[25]) mux_q_25 <= {mux_b_25, mux_a_25};

    reg [7:0] table_25;
    always @* begin
        case (a_25[4:0] ^ prev_25[4:0])
            5'd0: table_25 = 8'h54;
            5'd1: table_25 = 8'h47;
            5'd2: table_25 = 8'hac;
            5'd3: table_25 = 8'h24;
            5'd4: table_25 = 8'h75;
            5'd5: table_25 = 8'h4a;
            5'd6: table_25 = 8'h0e;
            5'd7: table_25 = 8'h9e;
            5'd8: table_25 = 8'hf3;
            5'd9: table_25 = 8'hd8;
            5'd10: table_25 = 8'h75;
            5'd11: table_25 = 8'hba;
            5'd12: table_25 = 8'h23;
            5'd13: table_25 = 8'h9c;
            5'd14: table_25 = 8'had;
            5'd15: table_25 = 8'h18;
            5'd16: table_25 = 8'hfd;
            5'd17: table_25 = 8'h85;
            5'd18: table_25 = 8'h4e;
            5'd19: table_25 = 8'h10;
            5'd20: table_25 = 8'hf4;
            5'd21: table_25 = 8'h2b;
            5'd22: table_25 = 8'h9f;
            5'd23: table_25 = 8'h10;
            5'd24: table_25 = 8'hd9;
            5'd25: table_25 = 8'h29;
            5'd26: table_25 = 8'h76;
            5'd27: table_25 = 8'hfb;
            5'd28: table_25 = 8'hbe;
            5'd29: table_25 = 8'h81;
            5'd30: table_25 = 8'h14;
            5'd31: table_25 = 8'h8b;
            default: table_25 = 8'h00;
        endcase
    end

    wire [7:0] compare_25;
    assign compare_25[0] = (a_25 == 8'h00);
    assign compare_25[1] = (a_25 == 8'h0f);
    assign compare_25[2] = (a_25 == 8'h33);
    assign compare_25[3] = (a_25 == 8'h55);
    assign compare_25[4] = (a_25 == 8'h66);
    assign compare_25[5] = (a_25 == 8'h99);
    assign compare_25[6] = (a_25 == 8'hc3);
    assign compare_25[7] = (a_25 == 8'hf0);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_25 =
        a_25[0] ? b_25 :
        a_25[1] ? prev_25 :
        a_25[2] ? sum_25 :
        a_25[3] ? diff_25 : blend_25;
    reg [7:0] auxiliary_25;
    always @(posedge clk)
        if (reset) auxiliary_25 <= 8'h00;
        else if (enable[25])
            auxiliary_25 <= table_25 ^ compare_25 ^ priority_25
                ^ mux_q_25[7:0] ^ mux_q_25[15:8];
    assign auxiliary[200 +: 8] = auxiliary_25;
    assign auxiliary[208 +: 8] = q_26 ^ q_25;
    assign auxiliary[216 +: 8] = q_27 ^ q_26;
    assign auxiliary[224 +: 8] = q_28 ^ q_27;
    assign auxiliary[232 +: 8] = q_29 ^ q_28;

    reg [7:0] mux_a_30, mux_b_30;
    always @* begin
        mux_a_30 = a_30 ^ prev_30;
        mux_b_30 = b_30 + prev_30;
        case (select_bus[90 +: 3])
            3'd0: begin mux_a_30 = a_30; mux_b_30 = b_30; end
            3'd1: begin mux_a_30 = b_30; mux_b_30 = a_30; end
            3'd2: begin mux_a_30 = prev_30; mux_b_30 = sum_30; end
            3'd3: begin mux_a_30 = sum_30; mux_b_30 = prev_30; end
            3'd4: begin mux_a_30 = diff_30; mux_b_30 = blend_30; end
            3'd5: begin mux_a_30 = blend_30; mux_b_30 = diff_30; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_30;
    always @(posedge clk)
        if (reset) mux_q_30 <= 16'h0000;
        else if (enable[30]) mux_q_30 <= {mux_b_30, mux_a_30};

    reg [7:0] table_30;
    always @* begin
        case (a_30[4:0] ^ prev_30[4:0])
            5'd0: table_30 = 8'h60;
            5'd1: table_30 = 8'h5d;
            5'd2: table_30 = 8'h4d;
            5'd3: table_30 = 8'h70;
            5'd4: table_30 = 8'h60;
            5'd5: table_30 = 8'h5d;
            5'd6: table_30 = 8'h9b;
            5'd7: table_30 = 8'h26;
            5'd8: table_30 = 8'h60;
            5'd9: table_30 = 8'h5d;
            5'd10: table_30 = 8'h4d;
            5'd11: table_30 = 8'h70;
            5'd12: table_30 = 8'h4d;
            5'd13: table_30 = 8'h5d;
            5'd14: table_30 = 8'h9b;
            5'd15: table_30 = 8'h8b;
            5'd16: table_30 = 8'h3e;
            5'd17: table_30 = 8'h83;
            5'd18: table_30 = 8'h93;
            5'd19: table_30 = 8'h2e;
            5'd20: table_30 = 8'h3e;
            5'd21: table_30 = 8'h83;
            5'd22: table_30 = 8'h45;
            5'd23: table_30 = 8'h78;
            5'd24: table_30 = 8'h3e;
            5'd25: table_30 = 8'h83;
            5'd26: table_30 = 8'h93;
            5'd27: table_30 = 8'h2e;
            5'd28: table_30 = 8'h93;
            5'd29: table_30 = 8'h83;
            5'd30: table_30 = 8'h45;
            5'd31: table_30 = 8'h55;
            default: table_30 = 8'h00;
        endcase
    end

    wire [7:0] compare_30;
    assign compare_30[0] = (a_30 == 8'ha0);
    assign compare_30[1] = (a_30 == 8'ha1);
    assign compare_30[2] = (a_30 == 8'ha2);
    assign compare_30[3] = (a_30 == 8'ha3);
    assign compare_30[4] = (a_30 == 8'ha4);
    assign compare_30[5] = (a_30 == 8'ha5);
    assign compare_30[6] = (a_30 == 8'ha6);
    assign compare_30[7] = (a_30 == 8'ha7);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_30 =
        a_30[0] ? b_30 :
        a_30[1] ? prev_30 :
        a_30[2] ? sum_30 :
        a_30[3] ? diff_30 : blend_30;
    reg [7:0] auxiliary_30;
    always @(posedge clk)
        if (reset) auxiliary_30 <= 8'h00;
        else if (enable[30])
            auxiliary_30 <= table_30 ^ compare_30 ^ priority_30
                ^ mux_q_30[7:0] ^ mux_q_30[15:8];
    assign auxiliary[240 +: 8] = auxiliary_30;

    reg [7:0] mux_a_31, mux_b_31;
    always @* begin
        mux_a_31 = a_31 ^ prev_31;
        mux_b_31 = b_31 + prev_31;
        case (select_bus[93 +: 3])
            3'd0: begin mux_a_31 = a_31; mux_b_31 = b_31; end
            3'd1: begin mux_a_31 = b_31; mux_b_31 = a_31; end
            3'd2: begin mux_a_31 = prev_31; mux_b_31 = sum_31; end
            3'd3: begin mux_a_31 = sum_31; mux_b_31 = prev_31; end
            3'd4: begin mux_a_31 = diff_31; mux_b_31 = left_31; end
            3'd5: begin mux_a_31 = blend_31; mux_b_31 = right_31; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_31;
    always @(posedge clk)
        if (reset) mux_q_31 <= 16'h0000;
        else if (enable[31]) mux_q_31 <= {mux_b_31, mux_a_31};

    reg [7:0] table_31;
    always @* begin
        case (a_31[4:0] ^ prev_31[4:0])
            5'd0: table_31 = 8'h48;
            5'd1: table_31 = 8'hef;
            5'd2: table_31 = 8'h8c;
            5'd3: table_31 = 8'ha0;
            5'd4: table_31 = 8'h87;
            5'd5: table_31 = 8'h9d;
            5'd6: table_31 = 8'hef;
            5'd7: table_31 = 8'h49;
            5'd8: table_31 = 8'hdb;
            5'd9: table_31 = 8'h83;
            5'd10: table_31 = 8'hdf;
            5'd11: table_31 = 8'h2b;
            5'd12: table_31 = 8'h1c;
            5'd13: table_31 = 8'h37;
            5'd14: table_31 = 8'h10;
            5'd15: table_31 = 8'h1e;
            5'd16: table_31 = 8'hd2;
            5'd17: table_31 = 8'h66;
            5'd18: table_31 = 8'h94;
            5'd19: table_31 = 8'hfd;
            5'd20: table_31 = 8'h11;
            5'd21: table_31 = 8'h34;
            5'd22: table_31 = 8'hba;
            5'd23: table_31 = 8'h0b;
            5'd24: table_31 = 8'h5b;
            5'd25: table_31 = 8'h9b;
            5'd26: table_31 = 8'hf1;
            5'd27: table_31 = 8'h51;
            5'd28: table_31 = 8'h82;
            5'd29: table_31 = 8'hc9;
            5'd30: table_31 = 8'ha5;
            5'd31: table_31 = 8'hfc;
            default: table_31 = 8'h00;
        endcase
    end

    wire [7:0] compare_31;
    assign compare_31[0] = (a_31 == 8'h00);
    assign compare_31[1] = (a_31 == 8'h0f);
    assign compare_31[2] = (a_31 == 8'h33);
    assign compare_31[3] = (a_31 == 8'h55);
    assign compare_31[4] = (a_31 == 8'h66);
    assign compare_31[5] = (a_31 == 8'h99);
    assign compare_31[6] = (a_31 == 8'hc3);
    assign compare_31[7] = (a_31 == 8'hf0);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_31 =
        a_31[0] ? b_31 :
        a_31[1] ? prev_31 :
        a_31[2] ? sum_31 :
        a_31[3] ? diff_31 : blend_31;
    reg [7:0] auxiliary_31;
    always @(posedge clk)
        if (reset) auxiliary_31 <= 8'h00;
        else if (enable[31])
            auxiliary_31 <= table_31 ^ compare_31 ^ priority_31
                ^ mux_q_31[7:0] ^ mux_q_31[15:8];
    assign auxiliary[248 +: 8] = auxiliary_31;
    assign auxiliary[256 +: 8] = q_32 ^ q_31;
    assign auxiliary[264 +: 8] = q_33 ^ q_32;
    assign auxiliary[272 +: 8] = q_34 ^ q_33;
    assign auxiliary[280 +: 8] = q_35 ^ q_34;

    reg [7:0] mux_a_36, mux_b_36;
    always @* begin
        mux_a_36 = a_36 ^ prev_36;
        mux_b_36 = b_36 + prev_36;
        case (select_bus[108 +: 3])
            3'd0: begin mux_a_36 = a_36; mux_b_36 = b_36; end
            3'd1: begin mux_a_36 = b_36; mux_b_36 = a_36; end
            3'd2: begin mux_a_36 = prev_36; mux_b_36 = sum_36; end
            3'd3: begin mux_a_36 = sum_36; mux_b_36 = prev_36; end
            3'd4: begin mux_a_36 = diff_36; mux_b_36 = blend_36; end
            3'd5: begin mux_a_36 = blend_36; mux_b_36 = diff_36; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_36;
    always @(posedge clk)
        if (reset) mux_q_36 <= 16'h0000;
        else if (enable[36]) mux_q_36 <= {mux_b_36, mux_a_36};

    reg [7:0] table_36;
    always @* begin
        case (a_36[4:0] ^ prev_36[4:0])
            5'd0: table_36 = 8'h60;
            5'd1: table_36 = 8'h5d;
            5'd2: table_36 = 8'h4d;
            5'd3: table_36 = 8'h70;
            5'd4: table_36 = 8'h60;
            5'd5: table_36 = 8'h5d;
            5'd6: table_36 = 8'h9b;
            5'd7: table_36 = 8'h26;
            5'd8: table_36 = 8'h60;
            5'd9: table_36 = 8'h5d;
            5'd10: table_36 = 8'h4d;
            5'd11: table_36 = 8'h70;
            5'd12: table_36 = 8'h4d;
            5'd13: table_36 = 8'h5d;
            5'd14: table_36 = 8'h9b;
            5'd15: table_36 = 8'h8b;
            5'd16: table_36 = 8'h3e;
            5'd17: table_36 = 8'h83;
            5'd18: table_36 = 8'h93;
            5'd19: table_36 = 8'h2e;
            5'd20: table_36 = 8'h3e;
            5'd21: table_36 = 8'h83;
            5'd22: table_36 = 8'h45;
            5'd23: table_36 = 8'h78;
            5'd24: table_36 = 8'h3e;
            5'd25: table_36 = 8'h83;
            5'd26: table_36 = 8'h93;
            5'd27: table_36 = 8'h2e;
            5'd28: table_36 = 8'h93;
            5'd29: table_36 = 8'h83;
            5'd30: table_36 = 8'h45;
            5'd31: table_36 = 8'h55;
            default: table_36 = 8'h00;
        endcase
    end

    wire [7:0] compare_36;
    assign compare_36[0] = (a_36 == 8'ha0);
    assign compare_36[1] = (a_36 == 8'ha1);
    assign compare_36[2] = (a_36 == 8'ha2);
    assign compare_36[3] = (a_36 == 8'ha3);
    assign compare_36[4] = (a_36 == 8'ha4);
    assign compare_36[5] = (a_36 == 8'ha5);
    assign compare_36[6] = (a_36 == 8'ha6);
    assign compare_36[7] = (a_36 == 8'ha7);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_36 =
        a_36[0] ? b_36 :
        a_36[1] ? prev_36 :
        a_36[2] ? sum_36 :
        a_36[3] ? diff_36 : blend_36;
    reg [7:0] auxiliary_36;
    always @(posedge clk)
        if (reset) auxiliary_36 <= 8'h00;
        else if (enable[36])
            auxiliary_36 <= table_36 ^ compare_36 ^ priority_36
                ^ mux_q_36[7:0] ^ mux_q_36[15:8];
    assign auxiliary[288 +: 8] = auxiliary_36;

    reg [7:0] mux_a_37, mux_b_37;
    always @* begin
        mux_a_37 = a_37 ^ prev_37;
        mux_b_37 = b_37 + prev_37;
        case (select_bus[111 +: 3])
            3'd0: begin mux_a_37 = a_37; mux_b_37 = b_37; end
            3'd1: begin mux_a_37 = b_37; mux_b_37 = a_37; end
            3'd2: begin mux_a_37 = prev_37; mux_b_37 = sum_37; end
            3'd3: begin mux_a_37 = sum_37; mux_b_37 = prev_37; end
            3'd4: begin mux_a_37 = diff_37; mux_b_37 = left_37; end
            3'd5: begin mux_a_37 = blend_37; mux_b_37 = right_37; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_37;
    always @(posedge clk)
        if (reset) mux_q_37 <= 16'h0000;
        else if (enable[37]) mux_q_37 <= {mux_b_37, mux_a_37};

    reg [7:0] table_37;
    always @* begin
        case (a_37[4:0] ^ prev_37[4:0])
            5'd0: table_37 = 8'h3c;
            5'd1: table_37 = 8'h96;
            5'd2: table_37 = 8'h6c;
            5'd3: table_37 = 8'h1c;
            5'd4: table_37 = 8'h99;
            5'd5: table_37 = 8'hf1;
            5'd6: table_37 = 8'hd0;
            5'd7: table_37 = 8'hf3;
            5'd8: table_37 = 8'hc4;
            5'd9: table_37 = 8'h2d;
            5'd10: table_37 = 8'h49;
            5'd11: table_37 = 8'h9d;
            5'd12: table_37 = 8'h16;
            5'd13: table_37 = 8'hd1;
            5'd14: table_37 = 8'h73;
            5'd15: table_37 = 8'h24;
            5'd16: table_37 = 8'ha7;
            5'd17: table_37 = 8'h46;
            5'd18: table_37 = 8'hd9;
            5'd19: table_37 = 8'hea;
            5'd20: table_37 = 8'h2d;
            5'd21: table_37 = 8'h3e;
            5'd22: table_37 = 8'hd5;
            5'd23: table_37 = 8'h06;
            5'd24: table_37 = 8'hdd;
            5'd25: table_37 = 8'h0d;
            5'd26: table_37 = 8'h6d;
            5'd27: table_37 = 8'ha6;
            5'd28: table_37 = 8'h47;
            5'd29: table_37 = 8'h10;
            5'd30: table_37 = 8'h36;
            5'd31: table_37 = 8'h6d;
            default: table_37 = 8'h00;
        endcase
    end

    wire [7:0] compare_37;
    assign compare_37[0] = (a_37 == 8'h00);
    assign compare_37[1] = (a_37 == 8'h0f);
    assign compare_37[2] = (a_37 == 8'h33);
    assign compare_37[3] = (a_37 == 8'h55);
    assign compare_37[4] = (a_37 == 8'h66);
    assign compare_37[5] = (a_37 == 8'h99);
    assign compare_37[6] = (a_37 == 8'hc3);
    assign compare_37[7] = (a_37 == 8'hf0);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_37 =
        a_37[0] ? b_37 :
        a_37[1] ? prev_37 :
        a_37[2] ? sum_37 :
        a_37[3] ? diff_37 : blend_37;
    reg [7:0] auxiliary_37;
    always @(posedge clk)
        if (reset) auxiliary_37 <= 8'h00;
        else if (enable[37])
            auxiliary_37 <= table_37 ^ compare_37 ^ priority_37
                ^ mux_q_37[7:0] ^ mux_q_37[15:8];
    assign auxiliary[296 +: 8] = auxiliary_37;
    assign auxiliary[304 +: 8] = q_38 ^ q_37;
    assign auxiliary[312 +: 8] = q_39 ^ q_38;
    assign auxiliary[320 +: 8] = q_40 ^ q_39;
    assign auxiliary[328 +: 8] = q_41 ^ q_40;

    reg [7:0] mux_a_42, mux_b_42;
    always @* begin
        mux_a_42 = a_42 ^ prev_42;
        mux_b_42 = b_42 + prev_42;
        case (select_bus[126 +: 3])
            3'd0: begin mux_a_42 = a_42; mux_b_42 = b_42; end
            3'd1: begin mux_a_42 = b_42; mux_b_42 = a_42; end
            3'd2: begin mux_a_42 = prev_42; mux_b_42 = sum_42; end
            3'd3: begin mux_a_42 = sum_42; mux_b_42 = prev_42; end
            3'd4: begin mux_a_42 = diff_42; mux_b_42 = blend_42; end
            3'd5: begin mux_a_42 = blend_42; mux_b_42 = diff_42; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_42;
    always @(posedge clk)
        if (reset) mux_q_42 <= 16'h0000;
        else if (enable[42]) mux_q_42 <= {mux_b_42, mux_a_42};

    reg [7:0] table_42;
    always @* begin
        case (a_42[4:0] ^ prev_42[4:0])
            5'd0: table_42 = 8'h60;
            5'd1: table_42 = 8'h5d;
            5'd2: table_42 = 8'h4d;
            5'd3: table_42 = 8'h70;
            5'd4: table_42 = 8'h60;
            5'd5: table_42 = 8'h5d;
            5'd6: table_42 = 8'h9b;
            5'd7: table_42 = 8'h26;
            5'd8: table_42 = 8'h60;
            5'd9: table_42 = 8'h5d;
            5'd10: table_42 = 8'h4d;
            5'd11: table_42 = 8'h70;
            5'd12: table_42 = 8'h4d;
            5'd13: table_42 = 8'h5d;
            5'd14: table_42 = 8'h9b;
            5'd15: table_42 = 8'h8b;
            5'd16: table_42 = 8'h3e;
            5'd17: table_42 = 8'h83;
            5'd18: table_42 = 8'h93;
            5'd19: table_42 = 8'h2e;
            5'd20: table_42 = 8'h3e;
            5'd21: table_42 = 8'h83;
            5'd22: table_42 = 8'h45;
            5'd23: table_42 = 8'h78;
            5'd24: table_42 = 8'h3e;
            5'd25: table_42 = 8'h83;
            5'd26: table_42 = 8'h93;
            5'd27: table_42 = 8'h2e;
            5'd28: table_42 = 8'h93;
            5'd29: table_42 = 8'h83;
            5'd30: table_42 = 8'h45;
            5'd31: table_42 = 8'h55;
            default: table_42 = 8'h00;
        endcase
    end

    wire [7:0] compare_42;
    assign compare_42[0] = (a_42 == 8'ha0);
    assign compare_42[1] = (a_42 == 8'ha1);
    assign compare_42[2] = (a_42 == 8'ha2);
    assign compare_42[3] = (a_42 == 8'ha3);
    assign compare_42[4] = (a_42 == 8'ha4);
    assign compare_42[5] = (a_42 == 8'ha5);
    assign compare_42[6] = (a_42 == 8'ha6);
    assign compare_42[7] = (a_42 == 8'ha7);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_42 =
        a_42[0] ? b_42 :
        a_42[1] ? prev_42 :
        a_42[2] ? sum_42 :
        a_42[3] ? diff_42 : blend_42;
    reg [7:0] auxiliary_42;
    always @(posedge clk)
        if (reset) auxiliary_42 <= 8'h00;
        else if (enable[42])
            auxiliary_42 <= table_42 ^ compare_42 ^ priority_42
                ^ mux_q_42[7:0] ^ mux_q_42[15:8];
    assign auxiliary[336 +: 8] = auxiliary_42;

    reg [7:0] mux_a_43, mux_b_43;
    always @* begin
        mux_a_43 = a_43 ^ prev_43;
        mux_b_43 = b_43 + prev_43;
        case (select_bus[129 +: 3])
            3'd0: begin mux_a_43 = a_43; mux_b_43 = b_43; end
            3'd1: begin mux_a_43 = b_43; mux_b_43 = a_43; end
            3'd2: begin mux_a_43 = prev_43; mux_b_43 = sum_43; end
            3'd3: begin mux_a_43 = sum_43; mux_b_43 = prev_43; end
            3'd4: begin mux_a_43 = diff_43; mux_b_43 = left_43; end
            3'd5: begin mux_a_43 = blend_43; mux_b_43 = right_43; end
            default: begin end
        endcase
    end
    reg [15:0] mux_q_43;
    always @(posedge clk)
        if (reset) mux_q_43 <= 16'h0000;
        else if (enable[43]) mux_q_43 <= {mux_b_43, mux_a_43};

    reg [7:0] table_43;
    always @* begin
        case (a_43[4:0] ^ prev_43[4:0])
            5'd0: table_43 = 8'h30;
            5'd1: table_43 = 8'h3e;
            5'd2: table_43 = 8'h4d;
            5'd3: table_43 = 8'h97;
            5'd4: table_43 = 8'hab;
            5'd5: table_43 = 8'h44;
            5'd6: table_43 = 8'hb1;
            5'd7: table_43 = 8'h9e;
            5'd8: table_43 = 8'hac;
            5'd9: table_43 = 8'hd8;
            5'd10: table_43 = 8'hb3;
            5'd11: table_43 = 8'h0e;
            5'd12: table_43 = 8'h0f;
            5'd13: table_43 = 8'h6c;
            5'd14: table_43 = 8'hd6;
            5'd15: table_43 = 8'h2a;
            5'd16: table_43 = 8'h7c;
            5'd17: table_43 = 8'h27;
            5'd18: table_43 = 8'h1f;
            5'd19: table_43 = 8'hd7;
            5'd20: table_43 = 8'h4a;
            5'd21: table_43 = 8'h47;
            5'd22: table_43 = 8'hf0;
            5'd23: table_43 = 8'h01;
            5'd24: table_43 = 8'h5f;
            5'd25: table_43 = 8'h7f;
            5'd26: table_43 = 8'he9;
            5'd27: table_43 = 8'hfb;
            5'd28: table_43 = 8'h0c;
            5'd29: table_43 = 8'h58;
            5'd30: table_43 = 8'hc7;
            5'd31: table_43 = 8'hde;
            default: table_43 = 8'h00;
        endcase
    end

    wire [7:0] compare_43;
    assign compare_43[0] = (a_43 == 8'h00);
    assign compare_43[1] = (a_43 == 8'h0f);
    assign compare_43[2] = (a_43 == 8'h33);
    assign compare_43[3] = (a_43 == 8'h55);
    assign compare_43[4] = (a_43 == 8'h66);
    assign compare_43[5] = (a_43 == 8'h99);
    assign compare_43[6] = (a_43 == 8'hc3);
    assign compare_43[7] = (a_43 == 8'hf0);

    // Priority controls may all be active: no one-hot assumption.
    wire [7:0] priority_43 =
        a_43[0] ? b_43 :
        a_43[1] ? prev_43 :
        a_43[2] ? sum_43 :
        a_43[3] ? diff_43 : blend_43;
    reg [7:0] auxiliary_43;
    always @(posedge clk)
        if (reset) auxiliary_43 <= 8'h00;
        else if (enable[43])
            auxiliary_43 <= table_43 ^ compare_43 ^ priority_43
                ^ mux_q_43[7:0] ^ mux_q_43[15:8];
    assign auxiliary[344 +: 8] = auxiliary_43;
    assign auxiliary[352 +: 8] = q_44 ^ q_43;
    assign auxiliary[360 +: 8] = q_45 ^ q_44;
    assign auxiliary[368 +: 8] = q_46 ^ q_45;
    assign auxiliary[376 +: 8] = q_47 ^ q_46;

endmodule

module stress_1k_mixed (
input wire clk, reset,
input wire [95:0] enable,
input wire [767:0] data_a, data_b,
input wire [287:0] select_bus,
output wire [767:0] result,
output wire [767:0] auxiliary
);
stress_1k_mixed_core u0 (.clk(clk), .reset(reset), .enable(enable[0 +: 48]), .data_a(data_a[0 +: 384]), .data_b(data_b[0 +: 384]), .select_bus(select_bus[0 +: 144]), .result(result[0 +: 384]), .auxiliary(auxiliary[0 +: 384]));
stress_1k_mixed_core u1 (.clk(clk), .reset(reset), .enable(enable[48 +: 48]), .data_a(data_a[384 +: 384]), .data_b(data_b[384 +: 384]), .select_bus(select_bus[144 +: 144]), .result(result[384 +: 384]), .auxiliary(auxiliary[384 +: 384]));
endmodule
