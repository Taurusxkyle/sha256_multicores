`timescale 1ns/1ns;
module Monitor(
    input clk,
    input output_valid,
    input [31:0]Hi0_1,
    input [31:0]Hi0_2,
    input [31:0]Hi0_3,
    input [31:0]Hi0_4,
    input [31:0]Hi0_5,
    input [31:0]Hi0_6,
    input [31:0]Hi0_7,
    input [31:0]Hi0_8
);
integer i;
reg error;
reg [6:0]total_error;
reg [255:0]Golden_Out[0:25];
reg [255:0]Now_Golden;
reg [31:0]Hi0_1_G;
reg [31:0]Hi0_2_G;
reg [31:0]Hi0_3_G;
reg [31:0]Hi0_4_G;
reg [31:0]Hi0_5_G;
reg [31:0]Hi0_6_G;
reg [31:0]Hi0_7_G;
reg [31:0]Hi0_8_G;

initial
begin
    $readmemh("out.txt",Golden_Out);
end

initial
begin
    i=1;
    total_error = 7'b0;
end
initial
begin
repeat(26)
    begin
        error = 0;
        Now_Golden = Golden_Out[i-1];
        Hi0_8_G = Now_Golden[1*32-1:0];
        Hi0_7_G = Now_Golden[2*32-1:1*32];
        Hi0_6_G = Now_Golden[3*32-1:2*32];
        Hi0_5_G = Now_Golden[4*32-1:3*32];
        Hi0_4_G = Now_Golden[5*32-1:4*32];
        Hi0_3_G = Now_Golden[6*32-1:5*32];
        Hi0_2_G = Now_Golden[7*32-1:6*32];
        Hi0_1_G = Now_Golden[8*32-1:7*32];
        @(posedge output_valid);
        @(posedge clk);
        if(Hi0_1 !== Hi0_1_G)
        begin
            error = 1;
            $display("Hi0_1 error!!\n");
            $display("expected is 0x%x , output is 0x%x",Hi0_1_G,Hi0_1);
        end
        if(Hi0_2 !== Hi0_2_G)
        begin
            error = 1;
            $display("Hi0_2 error!!\n");
            $display("expected is 0x%x , output is 0x%x",Hi0_2_G,Hi0_2);
        end
        if(Hi0_3 !== Hi0_3_G)
        begin
            error = 1;
            $display("Hi0_3 error!!\n");
            $display("expected is 0x%x , output is 0x%x",Hi0_3_G,Hi0_3);
        end
        if(Hi0_4 !== Hi0_4_G)
        begin
            error = 1;
            $display("Hi0_4 error!!\n");
            $display("expected is 0x%x , output is 0x%x",Hi0_4_G,Hi0_4);
        end
        if(Hi0_5 !== Hi0_5_G)
        begin
            error = 1;
            $display("Hi0_5 error!!\n");
            $display("expected is 0x%x , output is 0x%x",Hi0_5_G,Hi0_5);
        end
        if(Hi0_6 !== Hi0_6_G)
        begin
            error = 1;
            $display("Hi0_6 error!!\n");
            $display("expected is 0x%x , output is 0x%x",Hi0_6_G,Hi0_6);
        end
        if(Hi0_7 !== Hi0_7_G)
        begin
            error = 1;
            $display("Hi0_7 error!!\n");
            $display("expected is 0x%x , output is 0x%x",Hi0_7_G,Hi0_7);
        end
        if(Hi0_8 !== Hi0_8_G)
        begin
            error = 1;
            $display("Hi0_8 error!!\n");
            $display("expected is 0x%x , output is 0x%x",Hi0_8_G,Hi0_8);
        end
        if(!error)
            $display("No.%d test is ok!\n",i);
        else
        begin
            $display("No.%d test is wrong!\n",i);
            total_error = total_error + 1'b1;
        end
        i=i+1;
    end
    $display("total error : %d\n",total_error);
end

endmodule