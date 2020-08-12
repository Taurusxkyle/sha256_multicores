`define sha256_start sha256_tb.MY_FAKE_CPU.sha256_start

`timescale 1ns/1ns;
module testcase(
    input input_ready,
    input clk,
    input rst_n
);

reg [511:0]test_data[25:0];
integer i;

initial
begin
    $readmemh("data.txt",test_data);
    i=0;
    #50;
    repeat(26)
    begin
        $display("No.%d test start!!\n",i+1);
        `sha256_start(test_data[i]);
        i=i+1'b1;
        @(posedge input_ready);
    end
end

endmodule