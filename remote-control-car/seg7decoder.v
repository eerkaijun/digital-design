`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: School of Engineering, University of Edinburgh
// Engineer: Yijun Cheng
// 
// Create Date: 11/26/2019 03:45:13 PM
// Design Name: DSL_4_Mouse_Interface_assignment_1
// Module Name: Seg7_Wrapper
// Project Name: Mouse Interface
// Target Devices: Xilinx Basys 3
// Tool Versions: Xilinx Vivado 2015.2
// Description: generate hexout and selectout from the incoming numbers
// 
// Dependencies: bit_divider/generic_counter/Multiplexer/Seg7_Interface
// 
// Revision: 2.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 
module seg7decoder(
    input CLK,
    input [7:0] BUS_ADDR,
    input [7:0] BUS_DATA,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] SEG7_OUT
    );
    
    
    //Seg7BaseAddr     ---- Number_IN_L
    //Seg7BaseAddr + 1 ---- Number_IN_R
    parameter [7:0] Seg7BaseAddr = 8'hD0; //seg7 Base Address in the Memory Map
    reg [7:0] Number_IN_L;
    reg [7:0] Number_IN_R;
    always@(posedge CLK)begin
        if(BUS_ADDR == Seg7BaseAddr)  
            Number_IN_L  <= BUS_DATA; 
        if(BUS_ADDR == Seg7BaseAddr + 8'h01) 
            Number_IN_R <= BUS_DATA;        
    end    
    
    
    wire Trigg_99999;
    wire [1:0]Strobe_Signal;
    wire [3:0]Bit_Selected;
    wire [3:0]Bit_0;
    wire [3:0]Bit_1;
    wire [3:0]Bit_2;
    wire [3:0]Bit_3;

//-------------------divide number to display to 4 different bit-------------------
    bit_divider bit_divider(
         .CLK(CLK),
         .Number_IN_L(Number_IN_L),
         .Number_IN_R(Number_IN_R),
         .Bit_0_out(Bit_0),
         .Bit_1_out(Bit_1),
         .Bit_2_out(Bit_2),
         .Bit_3_out(Bit_3)
         );
//-------------------Counter for strobe frequency-------------------------
    generic_counter #(.WIDTH(17),.MAX(99999))
       Counter_STROBE_17_Bit(
       .CLK(CLK),
       .RESET(1'b0),
       .ENABLE(1'b1),
       .TRIG_OUT(Trigg_99999)
       );
    
    generic_counter #(.WIDTH(2),.MAX(3))
       Counter_STROBE_2_Bit(
       .CLK(CLK),
       .RESET(1'b0),
       .ENABLE(Trigg_99999),
       .COUNT(Strobe_Signal)
       );  
       
//-------------------Counter for strobe frequency-------------------------
    Multiplexer MUX_4( 
        .CLK(CLK),
        .Selection_Signal(Strobe_Signal),
        .IN0(Bit_0),
        .IN1(Bit_1),
        .IN2(Bit_2),
        .IN3(Bit_3),
        .OUT(Bit_Selected)
        );
//-------------------Seg_7 buttom level interface-------------------------
    Seg7_Interface Seg7_Interface(
        .SEG_SELECT_IN(Strobe_Signal),
        .HEX_OUT(SEG7_OUT),
        .SEG_SELECT_OUT(SEG_SELECT_OUT),
        .NUMBER_IN(Bit_Selected)
        );
               
endmodule
