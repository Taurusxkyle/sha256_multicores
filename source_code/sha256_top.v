`include "sha256_const.v"
module sha256_top(
    input [31:0]data_prepro,                //流水进入的数据，一次进入16个字（512bit）
    input clk,
    input rst_n,
    input data_load,
    output reg[31:0]Hi0_1,
    output reg[31:0]Hi0_2,
    output reg[31:0]Hi0_3,
    output reg[31:0]Hi0_4,
    output reg[31:0]Hi0_5,
    output reg[31:0]Hi0_6,
    output reg[31:0]Hi0_7,
    output reg[31:0]Hi0_8,
    output reg input_ready,
    output reg output_valid
);

reg [31:0] R1_A,R1_B,R1_C,R1_D,R1_E,R1_F,R1_G,R1_H;
reg [31:0] R2_A,R2_B,R2_C,R2_D,R2_E,R2_F,R2_G,R2_H;
reg [31:0] R3_A,R3_B,R3_C,R3_D,R3_E,R3_F,R3_G,R3_H;
reg [31:0] R4_A,R4_B,R4_C,R4_D,R4_E,R4_F,R4_G,R4_H;
wire [31:0]R1_A_next,R1_B_next,R1_C_next,R1_D_next,R1_E_next,R1_F_next,R1_G_next,R1_H_next;
wire [31:0]R2_A_next,R2_B_next,R2_C_next,R2_D_next,R2_E_next,R2_F_next,R2_G_next,R2_H_next;
wire [31:0]R3_A_next,R3_B_next,R3_C_next,R3_D_next,R3_E_next,R3_F_next,R3_G_next,R3_H_next;
wire [31:0]R4_A_next,R4_B_next,R4_C_next,R4_D_next,R4_E_next,R4_F_next,R4_G_next,R4_H_next;
reg [31:0]R1_Wt[15:0];
reg [31:0]R2_Wt[15:0];
reg [31:0]R3_Wt[15:0];
reg [31:0]R4_Wt[15:0];
reg [31:0]R1_Ktin,R2_Ktin,R3_Ktin,R4_Ktin;
reg [3:0]R1_cnt,R2_cnt,R3_cnt,R4_cnt;
reg load0,load1,load2,load3;
reg r1_Astart,r2_Astart,r3_Astart,r4_Astart;
reg r1_Dstart,r2_Dstart,r3_Dstart,r4_Dstart;
reg r1_Estart,r2_Estart,r3_Estart,r4_Estart;
reg r1_Hstart,r2_Hstart,r3_Hstart,r4_Hstart;
reg r2_cnt_start,r3_cnt_start,r4_cnt_start;
reg r1_ready,r1_ready1,r1_ready2,r1_ready3;
reg r2_ready,r2_ready1,r2_ready2,r2_ready3;
reg r3_ready,r3_ready1,r3_ready2,r3_ready3;
reg r4_ready,r4_ready1,r4_ready2,r4_ready3;
reg sha256_ready;
reg [31:0] R1_Cin,R1_Gin;
wire [31:0]R1_Wt1,R1_Wt6,R1_Wt14,R1_Wt15;
wire [31:0]R2_Wt1,R2_Wt6,R2_Wt14,R2_Wt15;
wire [31:0]R3_Wt1,R3_Wt6,R3_Wt14,R3_Wt15;
wire [31:0]R4_Wt1,R4_Wt6,R4_Wt14,R4_Wt15;

assign R1_Wt1 = R1_Wt[1];
assign R1_Wt6 = R1_Wt[6];
assign R1_Wt14 = R1_Wt[14];
assign R1_Wt15 = R1_Wt[15];
assign R2_Wt1 = R2_Wt[1];
assign R2_Wt6 = R2_Wt[6];
assign R2_Wt14 = R2_Wt[14];
assign R2_Wt15 = R2_Wt[15];
assign R3_Wt1 = R3_Wt[1];
assign R3_Wt6 = R3_Wt[6];
assign R3_Wt14 = R3_Wt[14];
assign R3_Wt15 = R3_Wt[15];
assign R4_Wt1 = R4_Wt[1];
assign R4_Wt6 = R4_Wt[6];
assign R4_Wt14 = R4_Wt[14];
assign R4_Wt15 = R4_Wt[15];
/*******************************************
         输出模块
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        Hi0_1 <= 32'd0;
        Hi0_2 <= 32'd0;
        Hi0_3 <= 32'd0;
        Hi0_4 <= 32'd0;
        Hi0_5 <= 32'd0;
        Hi0_6 <= 32'd0;
        Hi0_7 <= 32'd0;
        Hi0_8 <= 32'd0;
    end
    else if(sha256_ready)
    begin
        Hi0_1 <= `SHA256_H0 + R4_A;
        Hi0_2 <= `SHA256_H1 + R4_B;
        Hi0_3 <= `SHA256_H2 + R4_C;
        Hi0_4 <= `SHA256_H3 + R4_D;
        Hi0_5 <= `SHA256_H4 + R4_E;
        Hi0_6 <= `SHA256_H5 + R4_F;
        Hi0_7 <= `SHA256_H6 + R4_G;
        Hi0_8 <= `SHA256_H7 + R4_H;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        output_valid <= 1'b0;
    else if(sha256_ready)
        output_valid <= 1'b1;
    else 
        output_valid <= 1'b0;
end

/*******************************************
         计数控制单元
********************************************/

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R1_cnt <= 4'd0;
    else if(data_load)
        R1_cnt <= 4'd0;
    else if(R1_cnt == 4'd15)
        R1_cnt <= R1_cnt;
    else
        R1_cnt <= R1_cnt + 1'b1;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R2_cnt <= 4'd0;
    else if(r1_ready)
        R2_cnt <= 4'd0;
    else if(R2_cnt == 4'd15)
        R2_cnt <= R2_cnt;
    else if(r2_cnt_start)
        R2_cnt <= R2_cnt + 1'b1;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R3_cnt <= 4'd0;
    else if(r2_ready)
        R3_cnt <= 4'd0;
    else if(R3_cnt == 4'd15)
        R3_cnt <= R3_cnt;
    else if(r3_cnt_start)
        R3_cnt <= R3_cnt + 1'b1;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R4_cnt <= 4'd0;
    else if(r3_ready)
        R4_cnt <= 4'd0;
    else if(R4_cnt == 4'd15)
        R4_cnt <= R4_cnt;
    else if(r4_cnt_start)
        R4_cnt <= R4_cnt + 1'b1;
end

/**********************************************************************************
**********************************************************************************
       ************************  round1内核  ************************
**********************************************************************************
************************************************************************************/

/*******************************************
        round1控制信号单元
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        load0 <= 1'b0;
        load1 <= 1'b0;
        load2 <= 1'b0;
        load3 <= 1'b0;
    end
    else
    begin
        load0 <= data_load;
        load1 <= load0;
        load2 <= load1;
        load3 <= load2;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(R1_cnt == 4'd14)
        r1_ready <= 1'b1;
    else
        r1_ready <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r1_ready1 <= 1'b0;
        r1_ready2 <= 1'b0;
        r1_ready3 <= 1'b0;
    end
    else
    begin
        r1_ready1 <= r1_ready;
        r1_ready2 <= r1_ready1;
        r1_ready3 <= r1_ready2;
    end
end


always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r1_Hstart <= 1'b0;
    else if(data_load)
        r1_Hstart <= 1'b1;
    else if(r1_ready)
        r1_Hstart <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r1_Astart <= 1'b0;
    else if(load2)
        r1_Astart <= 1'b1;
    else if(r1_ready2)
        r1_Astart <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r1_Dstart <= 1'b0;
    else if(load0)
        r1_Dstart <= 1'b1;
    else if(r1_ready)
        r1_Dstart <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r1_Estart <= 1'b0;
    else if(load1)
        r1_Estart <= 1'b1;
    else if(r1_ready1)
        r1_Estart <= 1'b0;
end

always@(*)
begin
    input_ready = r1_ready3;
end


/*******************************************
        round1内核连接控制
********************************************/


always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R1_A <= 32'd0;
        R1_B <= 32'd0;
        R1_C <= 32'd0;
    end
    else if(data_load)
    begin
        R1_A <= `SHA256_H0;
        R1_B <= `SHA256_H1;
        R1_C <= `SHA256_H2;
    end
    else if(r1_Astart)
    begin
        R1_A <= R1_A_next;
        R1_B <= R1_B_next;
        R1_C <= R1_C_next;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R1_D <= 32'd0;
    else if(data_load)
        R1_D <= `SHA256_H3;
    else if(r1_Dstart)
        R1_D <= R1_D_next;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R1_E <= 32'd0;
        R1_F <= 32'd0;
        R1_G <= 32'd0;
    end
    else if(data_load)
    begin
        R1_E <= `SHA256_H4;
        R1_F <= `SHA256_H5;
        R1_G <= `SHA256_H6;
    end
    else if(r1_Estart)
    begin
        R1_E <= R1_E_next;
        R1_F <= R1_F_next;
        R1_G <= R1_G_next;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R1_H <= 32'd0;
    else if(data_load)
        R1_H <= `SHA256_H7;
    else if(r1_Hstart)
        R1_H <= R1_H_next;
end

always@(*)
begin
    if(load0)
        R1_Gin = R1_G;
    else if(load1)
        R1_Gin = R1_F;
    else
        R1_Gin = R1_E;
end

always@(*)
begin
    if(load1)
        R1_Cin = R1_C;
    else if(load2)
        R1_Cin = R1_B;
    else
        R1_Cin = R1_A;
end

/*******************************************
        round1内核例化
********************************************/
sha256_core round1_core(
    .clk(clk),
    .rst_n(rst_n),
    .A(R1_A),
    .B(R1_B),
    .C(R1_C),
    .D(R1_D),
    .E(R1_E),
    .F(R1_F),
    .G(R1_G),
    .H(R1_H),
    .Cin(R1_Cin),
    .Gin(R1_Gin),
    .Wt(R1_Wt[0]),
    .Kt(R1_Ktin),
    .A_next(R1_A_next),
    .B_next(R1_B_next),
    .C_next(R1_C_next),
    .D_next(R1_D_next),
    .E_next(R1_E_next),
    .F_next(R1_F_next),
    .G_next(R1_G_next),
    .H_next(R1_H_next)
);

/*******************************************
        round1 Wt,Kt寄存器
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R1_Wt[0] <= 32'd0;
        R1_Wt[1] <= 32'd0;
        R1_Wt[2] <= 32'd0;
        R1_Wt[3] <= 32'd0;
        R1_Wt[4] <= 32'd0;
        R1_Wt[5] <= 32'd0;
        R1_Wt[6] <= 32'd0;
        R1_Wt[7] <= 32'd0;
        R1_Wt[8] <= 32'd0;
        R1_Wt[9] <= 32'd0;
        R1_Wt[10] <= 32'd0;
        R1_Wt[11] <= 32'd0;
        R1_Wt[12] <= 32'd0;
        R1_Wt[13] <= 32'd0;
        R1_Wt[14] <= 32'd0;
        R1_Wt[15] <= 32'd0;
    end
    else if(data_load|r1_Hstart)
    begin
        R1_Wt[0] <= data_prepro;
        R1_Wt[1] <= R1_Wt[0];
        R1_Wt[2] <= R1_Wt[1];
        R1_Wt[3] <= R1_Wt[2];
        R1_Wt[4] <= R1_Wt[3];
        R1_Wt[5] <= R1_Wt[4];
        R1_Wt[6] <= R1_Wt[5];
        R1_Wt[7] <= R1_Wt[6];
        R1_Wt[8] <= R1_Wt[7];
        R1_Wt[9] <= R1_Wt[8];
        R1_Wt[10] <= R1_Wt[9];
        R1_Wt[11] <= R1_Wt[10];
        R1_Wt[12] <= R1_Wt[11];
        R1_Wt[13] <= R1_Wt[12];
        R1_Wt[14] <= R1_Wt[13];
        R1_Wt[15] <= R1_Wt[14];
    end
end

always@(*)
begin
    case(R1_cnt)
        4'd0: R1_Ktin = `K00;
        4'd1: R1_Ktin = `K01;
        4'd2: R1_Ktin = `K02;
        4'd3: R1_Ktin = `K03;
        4'd4: R1_Ktin = `K04;
        4'd5: R1_Ktin = `K05;
        4'd6: R1_Ktin = `K06;
        4'd7: R1_Ktin = `K07;
        4'd8: R1_Ktin = `K08;
        4'd9: R1_Ktin = `K09;
        4'd10: R1_Ktin = `K10;
        4'd11: R1_Ktin = `K11;
        4'd12: R1_Ktin = `K12;
        4'd13: R1_Ktin = `K13;
        4'd14: R1_Ktin = `K14;
        default: R1_Ktin = `K15;
    endcase
end

/**********************************************************************************
**********************************************************************************
       ************************  round2内核  ************************
**********************************************************************************
************************************************************************************/
/*******************************************
        round2控制信号单元
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r2_ready <= 1'b0;
    else if(R2_cnt == 4'd14)
        r2_ready <= 1'b1;
    else
        r2_ready <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r2_cnt_start <= 1'b0;
    else if(r1_ready)
        r2_cnt_start <= 1'b1;
    else if(r2_ready)
        r2_cnt_start <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r2_ready1 <= 1'b0;
        r2_ready2 <= 1'b0;
        r2_ready3 <= 1'b0;
    end
    else
    begin
        r2_ready1 <= r2_ready;
        r2_ready2 <= r2_ready1;
        r2_ready3 <= r2_ready2;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r2_Astart <= 1'b0; 
        r2_Dstart <= 1'b0;
    end
    else if(r1_ready3)
    begin
        r2_Astart <= 1'b1; 
        r2_Dstart <= 1'b1;
    end
    else if(r2_ready2)
        r2_Astart <= 1'b0;
    else if(r2_ready)
        r2_Dstart <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r2_Estart <= 1'b0; 
        r2_Hstart <= 1'b0;
    end
    else if(r1_ready2)
    begin
        r2_Estart <= 1'b1; 
        r2_Hstart <= 1'b1;
    end
    else if(r2_ready1)
        r2_Estart <= 1'b0;
    else if(r2_ready)
        r2_Hstart <= 1'b0;
end


/*******************************************
        round2内核连接控制
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R2_A <= 32'd0;
        R2_B <= 32'd0;
        R2_C <= 32'd0;
    end
    else if(r1_ready3)
    begin
        R2_A <= R1_A_next;
        R2_B <= R1_B_next;
        R2_C <= R1_C_next;
    end
    else if(r2_Astart)
    begin
        R2_A <= R2_A_next;
        R2_B <= R2_B_next;
        R2_C <= R2_C_next;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R2_D <= 32'd0;
    else if(r1_ready1|r1_ready2|r1_ready3)
        R2_D <= R1_D_next;
    else if(r2_Dstart)
        R2_D <= R2_D_next;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R2_E <= 32'd0;
        R2_F <= 32'd0;
        R2_G <= 32'd0;
    end
    else if(r1_ready2)
    begin
        R2_E <= R1_E_next;
        R2_F <= R1_F_next;
        R2_G <= R1_G_next;
    end
    else if(r2_Estart)
    begin
        R2_E <= R2_E_next;
        R2_F <= R2_F_next;
        R2_G <= R2_G_next;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R2_H <= 32'd0;
    else if(r1_ready|r1_ready1|r1_ready2)
        R2_H <= R1_H_next;
    else if(r2_Hstart)
        R2_H <= R2_H_next;
end


/*******************************************
        round2内核例化
********************************************/
sha256_core round2_core(
    .clk(clk),
    .rst_n(rst_n),
    .A(R2_A),
    .B(R2_B),
    .C(R2_C),
    .D(R2_D),
    .E(R2_E),
    .F(R2_F),
    .G(R2_G),
    .H(R2_H),
    .Cin(R2_A),
    .Gin(R2_E),
    .Wt(R2_Wt[0]),
    .Kt(R2_Ktin),
    .A_next(R2_A_next),
    .B_next(R2_B_next),
    .C_next(R2_C_next),
    .D_next(R2_D_next),
    .E_next(R2_E_next),
    .F_next(R2_F_next),
    .G_next(R2_G_next),
    .H_next(R2_H_next)
);
/*******************************************
        round2 Wt,Kt寄存器
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R2_Wt[0] <= 32'd0;
        R2_Wt[1] <= 32'd0;
        R2_Wt[2] <= 32'd0;
        R2_Wt[3] <= 32'd0;
        R2_Wt[4] <= 32'd0;
        R2_Wt[5] <= 32'd0;
        R2_Wt[6] <= 32'd0;
        R2_Wt[7] <= 32'd0;
        R2_Wt[8] <= 32'd0;
        R2_Wt[9] <= 32'd0;
        R2_Wt[10] <= 32'd0;
        R2_Wt[11] <= 32'd0;
        R2_Wt[12] <= 32'd0;
        R2_Wt[13] <= 32'd0;
        R2_Wt[14] <= 32'd0;
        R2_Wt[15] <= 32'd0;
    end
    else if(r1_ready)
    begin
        R2_Wt[0] <= ({R1_Wt1[16:0],R1_Wt1[31:17]} ^ {R1_Wt1[18:0],R1_Wt1[31:19]} ^ (R1_Wt1 >> 10)) + R1_Wt6 + ({R1_Wt14[6:0],R1_Wt14[31:7]} ^ {R1_Wt14[17:0],R1_Wt14[31:18]} ^ (R1_Wt14 >> 3)) + R1_Wt15;
        R2_Wt[1] <= R1_Wt[0];
        R2_Wt[2] <= R1_Wt[1];
        R2_Wt[3] <= R1_Wt[2];
        R2_Wt[4] <= R1_Wt[3];
        R2_Wt[5] <= R1_Wt[4];
        R2_Wt[6] <= R1_Wt[5];
        R2_Wt[7] <= R1_Wt[6];
        R2_Wt[8] <= R1_Wt[7];
        R2_Wt[9] <= R1_Wt[8];
        R2_Wt[10] <= R1_Wt[9];
        R2_Wt[11] <= R1_Wt[10];
        R2_Wt[12] <= R1_Wt[11];
        R2_Wt[13] <= R1_Wt[12];
        R2_Wt[14] <= R1_Wt[13];
        R2_Wt[15] <= R1_Wt[14];
    end
    else if(r2_cnt_start)
    begin
        R2_Wt[0] <= ({R2_Wt1[16:0],R2_Wt1[31:17]} ^ {R2_Wt1[18:0],R2_Wt1[31:19]} ^ (R2_Wt1 >> 10)) + R2_Wt6 + ({R2_Wt14[6:0],R2_Wt14[31:7]} ^ {R2_Wt14[17:0],R2_Wt14[31:18]} ^ (R2_Wt14 >> 3)) + R2_Wt15;
        R2_Wt[1] <= R2_Wt[0];  
        R2_Wt[2] <= R2_Wt[1];  
        R2_Wt[3] <= R2_Wt[2];  
        R2_Wt[4] <= R2_Wt[3];  
        R2_Wt[5] <= R2_Wt[4];  
        R2_Wt[6] <= R2_Wt[5];  
        R2_Wt[7] <= R2_Wt[6];  
        R2_Wt[8] <= R2_Wt[7];  
        R2_Wt[9] <= R2_Wt[8];  
        R2_Wt[10] <= R2_Wt[9];  
        R2_Wt[11] <= R2_Wt[10];  
        R2_Wt[12] <= R2_Wt[11];  
        R2_Wt[13] <= R2_Wt[12];  
        R2_Wt[14] <= R2_Wt[13];  
        R2_Wt[15] <= R2_Wt[14]; 
    end
end
always@(*)
begin
    case(R2_cnt)
        4'd0: R2_Ktin = `K16;
        4'd1: R2_Ktin = `K17;
        4'd2: R2_Ktin = `K18;
        4'd3: R2_Ktin = `K19;
        4'd4: R2_Ktin = `K20;
        4'd5: R2_Ktin = `K21;
        4'd6: R2_Ktin = `K22;
        4'd7: R2_Ktin = `K23;
        4'd8: R2_Ktin = `K24;
        4'd9: R2_Ktin = `K25;
        4'd10: R2_Ktin = `K26;
        4'd11: R2_Ktin = `K27;
        4'd12: R2_Ktin = `K28;
        4'd13: R2_Ktin = `K29;
        4'd14: R2_Ktin = `K30;
        default: R2_Ktin = `K31;
    endcase
end
/**********************************************************************************
**********************************************************************************
       ************************  round3内核  ************************
**********************************************************************************
************************************************************************************/
/*******************************************
        round3控制信号单元
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r3_ready <= 1'b0;
    else if(R3_cnt == 4'd14)
        r3_ready <= 1'b1;
    else 
        r3_ready <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r3_cnt_start <= 1'b0;
    else if(r2_ready)
        r3_cnt_start <= 1'b1;
    else if(r3_ready)
        r3_cnt_start <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r3_ready1 <= 1'b0;
        r3_ready2 <= 1'b0;
        r3_ready3 <= 1'b0;
    end
    else
    begin
        r3_ready1 <= r3_ready;
        r3_ready2 <= r3_ready1;
        r3_ready3 <= r3_ready2;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r3_Astart <= 1'b0; 
        r3_Dstart <= 1'b0;
    end
    else if(r2_ready3)
    begin
        r3_Astart <= 1'b1; 
        r3_Dstart <= 1'b1;
    end
    else if(r3_ready2)
        r3_Astart <= 1'b0;
    else if(r3_ready)
        r3_Dstart <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r3_Estart <= 1'b0; 
        r3_Hstart <= 1'b0;
    end
    else if(r2_ready2)
    begin
        r3_Estart <= 1'b1; 
        r3_Hstart <= 1'b1;
    end
    else if(r3_ready1)
        r3_Estart <= 1'b0;
    else if(r3_ready)
        r3_Hstart <= 1'b0;
end
/*******************************************
        round3内核连接控制
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R3_A <= 32'd0;
        R3_B <= 32'd0;
        R3_C <= 32'd0;
    end
    else if(r2_ready3)
    begin
        R3_A <= R2_A_next;
        R3_B <= R2_B_next;
        R3_C <= R2_C_next;
    end
    else if(r3_Astart)
    begin
        R3_A <= R3_A_next;
        R3_B <= R3_B_next;
        R3_C <= R3_C_next;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R3_D <= 32'd0;
    else if(r2_ready1|r2_ready2|r2_ready3)
        R3_D <= R2_D_next;
    else if(r3_Dstart)
        R3_D <= R3_D_next;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R3_E <= 32'd0;
        R3_F <= 32'd0;
        R3_G <= 32'd0;
    end
    else if(r2_ready2)
    begin
        R3_E <= R2_E_next;
        R3_F <= R2_F_next;
        R3_G <= R2_G_next;
    end
    else if(r3_Estart)
    begin
        R3_E <= R3_E_next;
        R3_F <= R3_F_next;
        R3_G <= R3_G_next;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R3_H <= 32'd0;
    else if(r2_ready|r2_ready1|r2_ready2)
        R3_H <= R2_H_next;
    else if(r3_Hstart)
        R3_H <= R3_H_next;
end
/*******************************************
        round3内核例化
********************************************/
sha256_core round3_core(
    .clk(clk),
    .rst_n(rst_n),
    .A(R3_A),
    .B(R3_B),
    .C(R3_C),
    .D(R3_D),
    .E(R3_E),
    .F(R3_F),
    .G(R3_G),
    .H(R3_H),
    .Cin(R3_A),
    .Gin(R3_E),
    .Wt(R3_Wt[0]),
    .Kt(R3_Ktin),
    .A_next(R3_A_next),
    .B_next(R3_B_next),
    .C_next(R3_C_next),
    .D_next(R3_D_next),
    .E_next(R3_E_next),
    .F_next(R3_F_next),
    .G_next(R3_G_next),
    .H_next(R3_H_next)
);
/*******************************************
        round3 Wt,Kt寄存器
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R3_Wt[0] <= 32'd0;
        R3_Wt[1] <= 32'd0;
        R3_Wt[2] <= 32'd0;
        R3_Wt[3] <= 32'd0;
        R3_Wt[4] <= 32'd0;
        R3_Wt[5] <= 32'd0;
        R3_Wt[6] <= 32'd0;
        R3_Wt[7] <= 32'd0;
        R3_Wt[8] <= 32'd0;
        R3_Wt[9] <= 32'd0;
        R3_Wt[10] <= 32'd0;
        R3_Wt[11] <= 32'd0;
        R3_Wt[12] <= 32'd0;
        R3_Wt[13] <= 32'd0;
        R3_Wt[14] <= 32'd0;
        R3_Wt[15] <= 32'd0;
    end
    else if(r2_ready)
    begin
        R3_Wt[0] <= ({R2_Wt1[16:0],R2_Wt1[31:17]} ^ {R2_Wt1[18:0],R2_Wt1[31:19]} ^ (R2_Wt1 >> 10)) + R2_Wt6 + ({R2_Wt14[6:0],R2_Wt14[31:7]} ^ {R2_Wt14[17:0],R2_Wt14[31:18]} ^ (R2_Wt14 >> 3)) + R2_Wt15;
        R3_Wt[1] <= R2_Wt[0];
        R3_Wt[2] <= R2_Wt[1];
        R3_Wt[3] <= R2_Wt[2];
        R3_Wt[4] <= R2_Wt[3];
        R3_Wt[5] <= R2_Wt[4];
        R3_Wt[6] <= R2_Wt[5];
        R3_Wt[7] <= R2_Wt[6];
        R3_Wt[8] <= R2_Wt[7];
        R3_Wt[9] <= R2_Wt[8];
        R3_Wt[10] <= R2_Wt[9];
        R3_Wt[11] <= R2_Wt[10];
        R3_Wt[12] <= R2_Wt[11];
        R3_Wt[13] <= R2_Wt[12];
        R3_Wt[14] <= R2_Wt[13];
        R3_Wt[15] <= R2_Wt[14];
    end
    else if(r3_cnt_start)
    begin
        R3_Wt[0] <= ({R3_Wt1[16:0],R3_Wt1[31:17]} ^ {R3_Wt1[18:0],R3_Wt1[31:19]} ^ (R3_Wt1 >> 10)) + R3_Wt6 + ({R3_Wt14[6:0],R3_Wt14[31:7]} ^ {R3_Wt14[17:0],R3_Wt14[31:18]} ^ (R3_Wt14 >> 3)) + R3_Wt15;
        R3_Wt[1] <= R3_Wt[0];  
        R3_Wt[2] <= R3_Wt[1];  
        R3_Wt[3] <= R3_Wt[2];  
        R3_Wt[4] <= R3_Wt[3];  
        R3_Wt[5] <= R3_Wt[4];  
        R3_Wt[6] <= R3_Wt[5];  
        R3_Wt[7] <= R3_Wt[6];  
        R3_Wt[8] <= R3_Wt[7];  
        R3_Wt[9] <= R3_Wt[8];  
        R3_Wt[10] <= R3_Wt[9];  
        R3_Wt[11] <= R3_Wt[10];  
        R3_Wt[12] <= R3_Wt[11];  
        R3_Wt[13] <= R3_Wt[12];  
        R3_Wt[14] <= R3_Wt[13];  
        R3_Wt[15] <= R3_Wt[14]; 
    end
end
always@(*)
begin
    case(R3_cnt)
        4'd0: R3_Ktin = `K32;
        4'd1: R3_Ktin = `K33;
        4'd2: R3_Ktin = `K34;
        4'd3: R3_Ktin = `K35;
        4'd4: R3_Ktin = `K36;
        4'd5: R3_Ktin = `K37;
        4'd6: R3_Ktin = `K38;
        4'd7: R3_Ktin = `K39;
        4'd8: R3_Ktin = `K40;
        4'd9: R3_Ktin = `K41;
        4'd10: R3_Ktin = `K42;
        4'd11: R3_Ktin = `K43;
        4'd12: R3_Ktin = `K44;
        4'd13: R3_Ktin = `K45;
        4'd14: R3_Ktin = `K46;
        default: R3_Ktin = `K47;
    endcase
end


/**********************************************************************************
**********************************************************************************
       ************************  round4内核  ************************
**********************************************************************************
************************************************************************************/
/*******************************************
        round4控制信号单元
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r4_ready <= 1'b0;
    else if(R4_cnt == 4'd14)
        r4_ready <= 1'b1;
    else
        r4_ready <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        r4_cnt_start <= 1'b0;
    else if(r3_ready)
        r4_cnt_start <= 1'b1;
    else if(r4_ready)
        r4_cnt_start <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r4_ready1 <= 1'b0;
        r4_ready2 <= 1'b0;
        r4_ready3 <= 1'b0;
    end
    else
    begin
        r4_ready1 <= r4_ready;
        r4_ready2 <= r4_ready1;
        r4_ready3 <= r4_ready2;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        sha256_ready <= 1'b0;
    else if(r4_ready3)
        sha256_ready = 1'b1;
    else
        sha256_ready = 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r4_Astart <= 1'b0; 
        r4_Dstart <= 1'b0;
    end
    else if(r3_ready3)
    begin
        r4_Astart <= 1'b1; 
        r4_Dstart <= 1'b1;
    end
    else if(r4_ready3)
        r4_Astart <= 1'b0;
    else if(r4_ready1)
        r4_Dstart <= 1'b0;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        r4_Estart <= 1'b0; 
        r4_Hstart <= 1'b0;
    end
    else if(r3_ready2)
    begin
        r4_Estart <= 1'b1; 
        r4_Hstart <= 1'b1;
    end
    else if(r4_ready2)
        r4_Estart <= 1'b0;
    else if(r4_ready)
        r4_Hstart <= 1'b0;
end
/*******************************************
        round4内核连接控制
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R4_A <= 32'd0;
        R4_B <= 32'd0;
        R4_C <= 32'd0;
    end
    else if(r3_ready3)
    begin
        R4_A <= R3_A_next;
        R4_B <= R3_B_next;
        R4_C <= R3_C_next;
    end
    else if(r4_Astart)
    begin
        R4_A <= R4_A_next;
        R4_B <= R4_B_next;
        R4_C <= R4_C_next;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R4_D <= 32'd0;
    else if(r3_ready1|r3_ready2|r3_ready3)
        R4_D <= R3_D_next;
    else if(r4_Dstart)
        R4_D <= R4_D_next;
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R4_E <= 32'd0;
        R4_F <= 32'd0;
        R4_G <= 32'd0;
    end
    else if(r3_ready2)
    begin
        R4_E <= R3_E_next;
        R4_F <= R3_F_next;
        R4_G <= R3_G_next;
    end
    else if(r4_Estart)
    begin
        R4_E <= R4_E_next;
        R4_F <= R4_F_next;
        R4_G <= R4_G_next;
    end
end

always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
        R4_H <= 32'd0;
    else if(r3_ready|r3_ready1|r3_ready2)
        R4_H <= R3_H_next;
    else if(r4_Hstart)
        R4_H <= R4_H_next;
end
/*******************************************
        round4内核例化
********************************************/
sha256_core round4_core(
    .clk(clk),
    .rst_n(rst_n),
    .A(R4_A),
    .B(R4_B),
    .C(R4_C),
    .D(R4_D),
    .E(R4_E),
    .F(R4_F),
    .G(R4_G),
    .H(R4_H),
    .Cin(R4_A),
    .Gin(R4_E),
    .Wt(R4_Wt[0]),
    .Kt(R4_Ktin),
    .A_next(R4_A_next),
    .B_next(R4_B_next),
    .C_next(R4_C_next),
    .D_next(R4_D_next),
    .E_next(R4_E_next),
    .F_next(R4_F_next),
    .G_next(R4_G_next),
    .H_next(R4_H_next)
);
/*******************************************
        round4 Wt,Kt寄存器
********************************************/
always@(posedge clk,negedge rst_n)
begin
    if(!rst_n)
    begin
        R4_Wt[0] <= 32'd0;
        R4_Wt[1] <= 32'd0;
        R4_Wt[2] <= 32'd0;
        R4_Wt[3] <= 32'd0;
        R4_Wt[4] <= 32'd0;
        R4_Wt[5] <= 32'd0;
        R4_Wt[6] <= 32'd0;
        R4_Wt[7] <= 32'd0;
        R4_Wt[8] <= 32'd0;
        R4_Wt[9] <= 32'd0;
        R4_Wt[10] <= 32'd0;
        R4_Wt[11] <= 32'd0;
        R4_Wt[12] <= 32'd0;
        R4_Wt[13] <= 32'd0;
        R4_Wt[14] <= 32'd0;
        R4_Wt[15] <= 32'd0;
    end
    else if(r3_ready)
    begin
        R4_Wt[0] <= ({R3_Wt1[16:0],R3_Wt1[31:17]} ^ {R3_Wt1[18:0],R3_Wt1[31:19]} ^ (R3_Wt1 >> 10)) + R3_Wt6 + ({R3_Wt14[6:0],R3_Wt14[31:7]} ^ {R3_Wt14[17:0],R3_Wt14[31:18]} ^ (R3_Wt14 >> 3)) + R3_Wt15;
        R4_Wt[1] <= R3_Wt[0];
        R4_Wt[2] <= R3_Wt[1];
        R4_Wt[3] <= R3_Wt[2];
        R4_Wt[4] <= R3_Wt[3];
        R4_Wt[5] <= R3_Wt[4];
        R4_Wt[6] <= R3_Wt[5];
        R4_Wt[7] <= R3_Wt[6];
        R4_Wt[8] <= R3_Wt[7];
        R4_Wt[9] <= R3_Wt[8];
        R4_Wt[10] <= R3_Wt[9];
        R4_Wt[11] <= R3_Wt[10];
        R4_Wt[12] <= R3_Wt[11];
        R4_Wt[13] <= R3_Wt[12];
        R4_Wt[14] <= R3_Wt[13];
        R4_Wt[15] <= R3_Wt[14];
    end
    else if(r4_cnt_start)
    begin
        R4_Wt[0] <= ({R4_Wt1[16:0],R4_Wt1[31:17]} ^ {R4_Wt1[18:0],R4_Wt1[31:19]} ^ (R4_Wt1 >> 10)) + R4_Wt6 + ({R4_Wt14[6:0],R4_Wt14[31:7]} ^ {R4_Wt14[17:0],R4_Wt14[31:18]} ^ (R4_Wt14 >> 3)) + R4_Wt15;
        R4_Wt[1] <= R4_Wt[0];  
        R4_Wt[2] <= R4_Wt[1];  
        R4_Wt[3] <= R4_Wt[2];  
        R4_Wt[4] <= R4_Wt[3];  
        R4_Wt[5] <= R4_Wt[4];  
        R4_Wt[6] <= R4_Wt[5];  
        R4_Wt[7] <= R4_Wt[6];  
        R4_Wt[8] <= R4_Wt[7];  
        R4_Wt[9] <= R4_Wt[8];  
        R4_Wt[10] <= R4_Wt[9];  
        R4_Wt[11] <= R4_Wt[10];  
        R4_Wt[12] <= R4_Wt[11];  
        R4_Wt[13] <= R4_Wt[12];  
        R4_Wt[14] <= R4_Wt[13];  
        R4_Wt[15] <= R4_Wt[14]; 
    end
end
always@(*)
begin
    case(R4_cnt)
        4'd0: R4_Ktin = `K48;
        4'd1: R4_Ktin = `K49;
        4'd2: R4_Ktin = `K50;
        4'd3: R4_Ktin = `K51;
        4'd4: R4_Ktin = `K52;
        4'd5: R4_Ktin = `K53;
        4'd6: R4_Ktin = `K54;
        4'd7: R4_Ktin = `K55;
        4'd8: R4_Ktin = `K56;
        4'd9: R4_Ktin = `K57;
        4'd10: R4_Ktin = `K58;
        4'd11: R4_Ktin = `K59;
        4'd12: R4_Ktin = `K60;
        4'd13: R4_Ktin = `K61;
        4'd14: R4_Ktin = `K62;
        default: R4_Ktin = `K63;
    endcase
end
endmodule