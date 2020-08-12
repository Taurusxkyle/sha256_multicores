`timescale 1ns/1ns;
module sha256_tb;
    wire clk;
    wire rst_n;
    wire input_ready;
    wire output_valid;
    wire [31:0]Hi0_1;
    wire [31:0]Hi0_2;
    wire [31:0]Hi0_3;
    wire [31:0]Hi0_4;
    wire [31:0]Hi0_5;
    wire [31:0]Hi0_6;
    wire [31:0]Hi0_7;
    wire [31:0]Hi0_8;
    wire [31:0]data_prepro;
    wire data_load;

    sha256_top MY_DUT(
        .data_prepro(data_prepro),
        .clk(clk),
        .rst_n(rst_n),
        .data_load(data_load),
        .Hi0_1(Hi0_1),
        .Hi0_2(Hi0_2),
        .Hi0_3(Hi0_3),
        .Hi0_4(Hi0_4),
        .Hi0_5(Hi0_5),
        .Hi0_6(Hi0_6),
        .Hi0_7(Hi0_7),
        .Hi0_8(Hi0_8),
        .input_ready(input_ready),
        .output_valid(output_valid)
    );

    Fake_CPU MY_FAKE_CPU(
        .data_prepro(data_prepro),
        .clk(clk),
        .rst_n(rst_n),
        .data_load(data_load)
    );

    testcase MY_testcase(
        .input_ready(input_ready),
        .clk(clk),
        .rst_n(rst_n)
    );

    Monitor MY_Monitor(
        .clk(clk),
        .output_valid(output_valid),
        .Hi0_1(Hi0_1),
        .Hi0_2(Hi0_2),
        .Hi0_3(Hi0_3),
        .Hi0_4(Hi0_4),
        .Hi0_5(Hi0_5),
        .Hi0_6(Hi0_6),
        .Hi0_7(Hi0_7),
        .Hi0_8(Hi0_8)
    );



endmodule