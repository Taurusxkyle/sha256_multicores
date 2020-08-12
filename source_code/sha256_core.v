
module sha256_core(
    input clk,
    input rst_n,
    input [31:0]A,
    input [31:0]B,
    input [31:0]C,
    input [31:0]D,
    input [31:0]E,
    input [31:0]F,
    input [31:0]G,
    input [31:0]H,
    input [31:0]Cin,
    input [31:0]Gin,
    input [31:0]Wt,
    input [31:0]Kt,
    output reg [31:0]A_next,
    output reg [31:0]B_next,
    output reg [31:0]C_next,
    output reg [31:0]D_next,
    output reg [31:0]E_next,
    output reg [31:0]F_next,
    output reg [31:0]G_next,
    output reg [31:0]H_next
);

reg [31:0] sigama,tao,U,namita;

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        sigama <= 32'd0;
    else
        sigama <= Wt + Kt + H;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        tao <= 32'd0;
    else
        tao <= sigama + D;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        U <= 32'd0;
    else
        U <= sigama;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        namita <= 32'd0;
    else
        namita <= U + ({E[5:0],E[31:6]} ^ {E[10:0],E[31:11]} ^ {E[24:0],E[31:25]}) + ((E&F)^((~E)&G));
end

always@(*) 
begin
    A_next = namita + ((A&B)^(A&C)^(B&C)) + ({A[1:0],A[31:2]} ^ {A[12:0],A[31:13]} ^ {A[21:0],A[31:22]}); 
    B_next = A;
    C_next = B;
    D_next = Cin;
    E_next = tao + ({E[5:0],E[31:6]} ^ {E[10:0],E[31:11]} ^ {E[24:0],E[31:25]}) + ((E&F)^((~E)&G));
    F_next = E;
    G_next = F;
    H_next = Gin;
end

endmodule