`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/14
// Module Name   : vga_pic
// Project Name  : vga_rom_pic
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 图像数据生成模块
// 
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  vga_wave_pic
(
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [9:0]   pix_x       ,   //输入有效显示区域像素点X轴坐标
    input   wire    [9:0]   pix_y       ,   //输入有效显示区域像素点Y轴坐标
	input   wire    [7:0]   pic_data    ,    //自ROM读出的图片数据
	
    input   wire    [2:0]   FRE_select  ,
	input   wire    [1:0]   RAN_select  , 

    output  wire    [15:0]  pix_data_out,   //输出VGA显示图像数据
    output  reg     [9:0]	ram_rd_addr
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

parameter   H_VALID =   10'd640     ,   //行有效数据
            V_VALID =   10'd480     ;   //场有效数据

parameter   PIC_SIZE=   10'd640   ;   //波形像素个数

parameter   RED     =   16'hF800    ,   //红色
            ORANGE  =   16'hFC00    ,   //橙色
            YELLOW  =   16'hFFE0    ,   //黄色
            GREEN   =   16'h07E0    ,   //绿色
            CYAN    =   16'h07FF    ,   //青色
            BLUE    =   16'h001F    ,   //蓝色
            PURPPLE =   16'hF81F    ,   //紫色
            BLACK   =   16'h0000    ,   //黑色
            WHITE   =   16'hFFFF    ,   //白色
            GRAY    =   16'hD69A    ,   //灰色
			GOLDEN  =   16'hFEC0    ;   //金色
			
parameter   FRE_ONE     =   3'b001,
            FRE_TWO     =   3'b010,
			FRE_THREE   =   3'b011,
			FRE_FOUR    =   3'b100,
            FRE_FIVE    =   3'b101;
			
parameter   RAN_ONE     =   2'b01,
            RAN_TWO     =   2'b10,
			RAN_THREE   =   2'b11;
			
parameter   CHAR_t_B_H=   10'd623 ,   //字符开始X轴坐标
            CHAR_t_B_V=   10'd247 ;   //字符开始Y轴坐标

parameter   CHAR_t_W  =   10'd16 ,   //字符宽度
            CHAR_t_H  =   10'd6  ;   //字符高度		
			
parameter   CHAR_O_B_H=   10'd13 ,   //字符开始X轴坐标
            CHAR_O_B_V=   10'd243 ;   //字符开始Y轴坐标

parameter   CHAR_O_W  =   10'd7 ,   //字符宽度
            CHAR_O_H  =   10'd6  ;   //字符高度
			
parameter   CHAR_N_B_H=   10'd40 ,   //字符开始X轴坐标
            CHAR_N_B_V=   10'd233 ;   //字符开始Y轴坐标

parameter   CHAR_N_W  =   10'd21 ,   //字符宽度
            CHAR_N_H  =   10'd6  ;   //字符高度
			
reg     [15:0] char_t    [5:0]  ;   //字符数据
reg     [ 6:0] char_O    [5:0]  ;   //字符数据
reg     [ 19:0] char_N    [5:0]  ;   //字符数据

wire    [9:0]   char_t_x  ;   //字符显示X轴坐标
wire    [9:0]   char_t_y  ;   //字符显示Y轴坐标
wire    [9:0]   char_O_x  ;   //字符显示X轴坐标
wire    [9:0]   char_O_y  ;   //字符显示Y轴坐标
wire    [9:0]   char_N_x  ;   //字符显示X轴坐标
wire    [9:0]   char_N_y  ;   //字符显示Y轴坐标

reg    [2:0]   FRE             ;
reg    [1:0]   RAN             ;

reg    [7:0]   pre_pic_data    ;   //自ROM读出的图片数据
reg    [15:0]  pix_data        ;   //背景色彩信息

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//char:字符数据t/s
always@(posedge vga_clk)
    begin
	    char_t[0]     <=  16'b0010000000101110;        
        char_t[1]     <=  16'b0010000001011111;
        char_t[2]     <=  16'b1111100010111000;
        char_t[3]     <=  16'b0010000100001110;
        char_t[4]     <=  16'b0010101001111100;
        char_t[5]     <=  16'b0011010000111000;    
    end
	
//char:字符数据0
always@(posedge vga_clk)
    begin
	    char_O[0]     <=  7'b0011100;        
        char_O[1]     <=  7'b0110110;
        char_O[2]     <=  7'b1100011;
        char_O[3]     <=  7'b1100011;
        char_O[4]     <=  7'b0110110;
        char_O[5]     <=  7'b0011100;    
    end
	
//char:字符数据0
always@(posedge vga_clk)
 case(FRE_select)
    FRE_ONE  :    
	 begin
	    char_N[0]     <=  20'b01111000011110011000;        
        char_N[1]     <=  20'b01001000010010011000;
        char_N[2]     <=  20'b01001000010010011000;
        char_N[3]     <=  20'b01001000010010011000;
        char_N[4]     <=  20'b01001000010010011000;
        char_N[5]     <=  20'b01111010011110011000;   
     end
	FRE_TWO  : 
	 begin
	    char_N[0]     <=  20'b01111000011110011111;        
        char_N[1]     <=  20'b01001000010010000001;
        char_N[2]     <=  20'b01001000010010011111;
        char_N[3]     <=  20'b01001000010010010000;
        char_N[4]     <=  20'b01001000010010010000;
        char_N[5]     <=  20'b01111010011110011111; 
     end
    FRE_THREE: 
	 begin
	    char_N[0]     <=  20'b01111000011110011111;        
        char_N[1]     <=  20'b01001000010010000001;
        char_N[2]     <=  20'b01001000010010011111;
        char_N[3]     <=  20'b01001000010010000001;
        char_N[4]     <=  20'b01001000010010000001;
        char_N[5]     <=  20'b01111010011110011111; 
     end
	FRE_FOUR :
	 begin
	    char_N[0]     <=  20'b01111000011110010001;        
        char_N[1]     <=  20'b01001000010010010001;
        char_N[2]     <=  20'b01001000010010011111;
        char_N[3]     <=  20'b01001000010010000001;
        char_N[4]     <=  20'b01001000010010000001;
        char_N[5]     <=  20'b01111010011110000001;  
     end
    FRE_FIVE :
	begin
	    char_N[0]     <=  20'b01111000011110011111;        
        char_N[1]     <=  20'b01001000010010010000;
        char_N[2]     <=  20'b01001000010010011111;
        char_N[3]     <=  20'b01001000010010000001;
        char_N[4]     <=  20'b01001000010010000001;
        char_N[5]     <=  20'b01111010011110011111;
     end
	 default:
    begin
	    char_N[0]     <=  20'b01111000011110011000;        
        char_N[1]     <=  20'b01001000010010011000;
        char_N[2]     <=  20'b01001000010010011000;
        char_N[3]     <=  20'b01001000010010011000;
        char_N[4]     <=  20'b01001000010010011000;
        char_N[5]     <=  20'b01111010011110011000; 
    end
	endcase
	
//字符显示坐标t/s
assign  char_t_x  =   (((pix_x >= CHAR_t_B_H) && (pix_x < (CHAR_t_B_H + CHAR_t_W)))
                    && ((pix_y >= CHAR_t_B_V) && (pix_y < (CHAR_t_B_V + CHAR_t_H))))
                    ? (pix_x - CHAR_t_B_H) : 10'h3FF;
assign  char_t_y  =   (((pix_x >= CHAR_t_B_H) && (pix_x < (CHAR_t_B_H + CHAR_t_W)))
                    && ((pix_y >= CHAR_t_B_V) && (pix_y < (CHAR_t_B_V + CHAR_t_H))))
                    ? (pix_y - CHAR_t_B_V) : 10'h3FF;
					
//字符显示坐标o
assign  char_O_x  =   (((pix_x >= CHAR_O_B_H) && (pix_x < (CHAR_O_B_H + CHAR_O_W)))
                    && ((pix_y >= CHAR_O_B_V) && (pix_y < (CHAR_O_B_V + CHAR_O_H))))
                    ? (pix_x - CHAR_O_B_H) : 10'h3FF;
assign  char_O_y  =   (((pix_x >= CHAR_O_B_H) && (pix_x < (CHAR_O_B_H + CHAR_O_W)))
                    && ((pix_y >= CHAR_O_B_V) && (pix_y < (CHAR_O_B_V + CHAR_O_H))))
                    ? (pix_y - CHAR_O_B_V) : 10'h3FF;
					
//字符显示坐标o
assign  char_N_x  =   (((pix_x >= CHAR_N_B_H) && (pix_x < (CHAR_N_B_H + CHAR_N_W)))
                    && ((pix_y >= CHAR_N_B_V) && (pix_y < (CHAR_N_B_V + CHAR_N_H))))
                    ? (pix_x - CHAR_N_B_H) : 10'h3FF;
assign  char_N_y  =   (((pix_x >= CHAR_N_B_H) && (pix_x < (CHAR_N_B_H + CHAR_N_W)))
                    && ((pix_y >= CHAR_N_B_V) && (pix_y < (CHAR_N_B_V + CHAR_N_H))))
                    ? (pix_y - CHAR_N_B_V) : 10'h3FF;
		
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
	    pre_pic_data <= 1'b0;
	else
	    pre_pic_data <= pic_data;
	
assign pix_data_out = ((pix_y + ((9'd480 - (8'd255 / RAN)) / 2))) == (9'd480 - (pre_pic_data / RAN)) ? RED : pix_data;
 
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
	      FRE <= 3'd0;
	else
	    case(FRE_select)
		  FRE_ONE  : FRE <= FRE_ONE;
		  FRE_TWO  : FRE <= FRE_TWO;
		  FRE_THREE: FRE <= FRE_THREE;
		  FRE_FOUR : FRE <= FRE_FOUR;
		  FRE_FIVE : FRE <= FRE_FIVE;
		  default  :FRE <= FRE_ONE;
        endcase	

always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
	    RAN <= 2'd0;
	else
	    case(RAN_select)
		  RAN_ONE  : RAN <= RAN_ONE;
		  RAN_TWO  : RAN <= RAN_TWO;
		  RAN_THREE: RAN <= RAN_THREE;
		  default  : RAN <= RAN_ONE;
        endcase		
		
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pix_data    <= 16'd0;
	else    if(((pix_x == (H_VALID/32)*0)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;	
    else    if(((pix_x == (H_VALID/32)*1)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*2)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10))&&(pix_y != 240))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*3)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*4)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*5)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*6)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*7)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*8)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*9)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*10)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*11)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if(((pix_x == (H_VALID/32)*12)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if(((pix_x == (H_VALID/32)*13)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*14)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if(((pix_x == (H_VALID/32)*15)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if(((pix_x == (H_VALID/32)*16)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if(((pix_x == (H_VALID/32)*17)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;	
    else    if(((pix_x == (H_VALID/32)*18)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*19)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*20)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*21)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*22)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*23)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*24)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*25)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*26)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*27)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*28)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if(((pix_x == (H_VALID/32)*29)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if(((pix_x == (H_VALID/32)*30)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
    else    if(((pix_x == (H_VALID/32)*31)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if(((pix_x == (H_VALID/32)*32)) && (pix_y <=(240 + (8'd255 /2'b10))) && (pix_y >=(240 - (8'd255 )/2'b10)))
        pix_data    <=  GREEN;
	else    if((pix_y == (240 - (8'd255 /2'b10))) || (pix_y==(240 + (8'd255/2'b10)))||(pix_y == 240))
        pix_data    <=  GREEN;
	else    if(((pix_x == 10'd638)&&(pix_y == 10'd239 || pix_y == 10'd241)) || ((pix_x == 10'd637)&&(pix_y == 10'd238 || pix_y == 10'd242)))
       	pix_data    <=  GREEN;
	else    if(((pix_x == 10'd636)&&(pix_y == 10'd237 || pix_y == 10'd243)) || ((pix_x == 10'd635)&&(pix_y == 10'd236 || pix_y == 10'd244)))
       	pix_data    <=  GREEN;
	else    if(((pix_y == 10'd114)&&(pix_x == 10'd19 || pix_x == 10'd21)) || ((pix_y == 10'd115)&&(pix_x == 10'd18 || pix_x == 10'd22)))
       	pix_data    <=  GREEN;
	else    if(((pix_y == 10'd116)&&(pix_x == 10'd17 || pix_x == 10'd23)) || ((pix_y == 10'd117)&&(pix_x == 10'd16 || pix_x == 10'd24)))
       	pix_data    <=  GREEN;
	else    if((pix_x >= 0) && (pix_x < (H_VALID/10)*1) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  RED;
    else    if((pix_x >= (H_VALID/10)*1) && (pix_x < (H_VALID/10)*2) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  ORANGE;
    else    if((pix_x >= (H_VALID/10)*2) && (pix_x < (H_VALID/10)*3) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  YELLOW;
    else    if((pix_x >= (H_VALID/10)*3) && (pix_x < (H_VALID/10)*4) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  GREEN;
    else    if((pix_x >= (H_VALID/10)*4) && (pix_x < (H_VALID/10)*5) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  CYAN;
    else    if((pix_x >= (H_VALID/10)*5) && (pix_x < (H_VALID/10)*6) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  BLUE;
    else    if((pix_x >= (H_VALID/10)*6) && (pix_x < (H_VALID/10)*7) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  PURPPLE;
    else    if((pix_x >= (H_VALID/10)*7) && (pix_x < (H_VALID/10)*8) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  BLACK;
    else    if((pix_x >= (H_VALID/10)*8) && (pix_x < (H_VALID/10)*9) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  WHITE;
    else    if((pix_x >= (H_VALID/10)*9) && (pix_x < H_VALID) && ((pix_y >=(240 + (8'd255 /2'b10))) || (pix_y <=(240 - (8'd255 )/2'b10))))
        pix_data    <=  GRAY;
	else    if((((pix_x >= (CHAR_t_B_H - 1'b1))
                && (pix_x < (CHAR_t_B_H + CHAR_t_W -1'b1)))
                && ((pix_y >= CHAR_t_B_V) && (pix_y < (CHAR_t_B_V + CHAR_t_H))))
                && (char_t[char_t_y][8'd15 - char_t_x] == 1'b1))
                   pix_data    <=  GOLDEN;
	else    if((((pix_x >= (CHAR_O_B_H - 1'b1))
                && (pix_x < (CHAR_O_B_H + CHAR_O_W -1'b1)))
                && ((pix_y >= CHAR_O_B_V) && (pix_y < (CHAR_O_B_V + CHAR_O_H))))
                && (char_O[char_O_y][8'd6 - char_O_x] == 1'b1))
                   pix_data    <=  GOLDEN;
	else    if((((pix_x >= (CHAR_N_B_H - 1'b1))
                && (pix_x < (CHAR_N_B_H + CHAR_N_W -1'b1)))
                && ((pix_y >= CHAR_N_B_V) && (pix_y < (CHAR_N_B_V + CHAR_N_H))))
                && (char_N[char_N_y][8'd19 - char_N_x] == 1'b1))
                   pix_data    <=  GOLDEN;
    else    if((pix_x == 40)&&(pix_y == 240))
	    pix_data    <=  RED;
    else
        pix_data    <=  BLACK;
		
//ram_addr:读RAM地址
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        ram_rd_addr <=  10'd0;
    else    if(ram_rd_addr == (PIC_SIZE - FRE - (PIC_SIZE % FRE)))
        ram_rd_addr <=  10'd0;
    else    if(pix_x < (PIC_SIZE-1'b1))
        ram_rd_addr <=  ram_rd_addr + FRE;
	else 
	    ram_rd_addr <= 10'd0;
		
endmodule
