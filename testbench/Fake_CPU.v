`timescale 1ns/1ns;
module Fake_CPU(
    output reg [31:0]data_prepro,
    output reg clk,
    output reg rst_n,
    output reg data_load
);

reg [511:0]data_ori;

initial
begin
    clk = 0;
    rst_n = 1;
    #10 rst_n = 0;
    data_prepro = 32'b0;
    data_load = 1'b0;
    #10 rst_n = 1;
end

always
    #10 clk=~clk;

task sha256_start;
input [511:0]data;
begin
    data_ori = data;
    @(posedge clk) data_load = 1; data_prepro = data_ori[16*32-1:15*32];
    @(posedge clk) data_load = 0; data_prepro = data_ori[15*32-1:14*32];
    @(posedge clk) data_prepro = data_ori[14*32-1:13*32];
    @(posedge clk) data_prepro = data_ori[13*32-1:12*32];
    @(posedge clk) data_prepro = data_ori[12*32-1:11*32];
    @(posedge clk) data_prepro = data_ori[11*32-1:10*32];
    @(posedge clk) data_prepro = data_ori[10*32-1:9*32];
    @(posedge clk) data_prepro = data_ori[9*32-1:8*32];
    @(posedge clk) data_prepro = data_ori[8*32-1:7*32];
    @(posedge clk) data_prepro = data_ori[7*32-1:6*32];
    @(posedge clk) data_prepro = data_ori[6*32-1:5*32];
    @(posedge clk) data_prepro = data_ori[5*32-1:4*32];
    @(posedge clk) data_prepro = data_ori[4*32-1:3*32];
    @(posedge clk) data_prepro = data_ori[3*32-1:2*32];
    @(posedge clk) data_prepro = data_ori[2*32-1:1*32];
    @(posedge clk) data_prepro = data_ori[1*32-1:0];
end
endtask

endmodule