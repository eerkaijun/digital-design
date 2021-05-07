`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2019 13:59:10
// Design Name: 
// Module Name: VGA_Wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Wrapper(
    input CLK,
    input [11:0] COLOUR_INPUT,
    input [1:0] MASTER_STATE,
    output [9:0] ADDRH,
    output [8:0] ADDRV,
    output [11:0] COLOUR_OUT,
    output HS,
    output VS
    );
    
    wire [11:0] COLOUR_IN;
    wire [9:0] horizontal;
    wire [8:0] vertical;
    
    assign ADDRH = horizontal;
    assign ADDRV = vertical;
    
    VGA_Interface vga(
      .CLK(CLK),
      .COLOUR_IN(COLOUR_IN),
      .ADDRH(horizontal),
      .ADDRV(vertical),
      .COLOUR_OUT(COLOUR_OUT),
      .HS(HS),
      .VS(VS)
    );
    
    VGA_display display (
      .CLK(CLK),
      .MASTER_STATE(MASTER_STATE),
      .COLOUR_SNAKE(COLOUR_INPUT),
      .ADDRH(horizontal),
      .ADDRV(vertical),
      .COLOUR_OUT(COLOUR_IN)
    );
    
endmodule
