`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2019 10:01:35
// Design Name: 
// Module Name: VGA_Interface
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


module VGA_Interface(
    input CLK,
    input [11:0] COLOUR_IN,
    output reg [11:0] COLOUR_OUT,
    output reg [9:0] ADDRH,
    output reg [8:0] ADDRV,
    output reg HS,
    output reg VS
    );
    
    //Time is vertical lines
    parameter VertTimeToPulseWidthEnd  = 10'd2;
    parameter VertTimeToBackPorchEnd  = 10'd31;
    parameter VertTimeToDisplayEnd  = 10'd511;
    parameter VertTimeToFrontPorchEnd  = 10'd521;

    //Time is front horizontal lines
    parameter HorzTimeToPulseWidthEnd  = 10'd96;
    parameter HorzTimeToBackPorchEnd  = 10'd144;
    parameter HorzTimeToDisplayEnd  = 10'd784;
    parameter HorzTimeToFrontPorchEnd  = 10'd800; 
    
    wire FreqAdjust; //Connect the frequency converter to the horizontal counter
    wire Connect; //Connect the horizontal counter to the vertical counter
    wire [9:0] HorizontalCount;
    wire [9:0] VerticalCount;
    
    //Timing counter to convert the 100MHz internal clock frequency to a 25MHz frequency passed to the horizontal counter
    Generic_counter # (.COUNTER_WIDTH(2),
                       .COUNTER_MAX(3)
                       )
                       VGAFrequency (
                       .CLK(CLK),
                       .ENABLE(1'b1),
                       .TRIG_OUT(FreqAdjust)
                       );
    
    //Horizontal counter that increments by one every adjusted clock cycle
    Generic_counter # (.COUNTER_WIDTH(10),
                       .COUNTER_MAX(799)
                       )
                       HorzCounter (
                       .CLK(CLK),
                       .ENABLE(FreqAdjust),
                       .TRIG_OUT(Connect),
                       .COUNT(HorizontalCount)
                       ); 
    
    //Vertical counter that increments by one everytime the horizontal counter reaches its maximum
    Generic_counter # (.COUNTER_WIDTH(10),
                       .COUNTER_MAX(520)
                       )
                       VertCounter (
                       .CLK(CLK),
                       .ENABLE(Connect),
                       .COUNT(VerticalCount)
                       );
                       
    always@(posedge CLK) begin
      if(HorizontalCount <= HorzTimeToPulseWidthEnd) 
        HS <= 0;
      else 
        HS <= 1;
    end 
    
    always@(posedge CLK) begin
      if(VerticalCount <= VertTimeToPulseWidthEnd) 
        VS <= 0;
      else 
        VS <= 1;
    end
    
    //COLOUR_OUT only takes the value of COLOUR_IN when within both horizontal and vertical display ranges
    always@(posedge CLK) begin
      if(HorizontalCount > HorzTimeToBackPorchEnd && HorizontalCount < HorzTimeToDisplayEnd) begin
        if(VerticalCount > VertTimeToBackPorchEnd && VerticalCount < VertTimeToDisplayEnd)
          COLOUR_OUT <= COLOUR_IN;
        else 
          COLOUR_OUT <= 12'h000;
      end
      else
        COLOUR_OUT <= 12'h000;
    end
    
    //Decode the address bits
    //Address bits should take the value of 0 when not within the display range
    always@(posedge CLK) begin
      if(HorizontalCount > HorzTimeToBackPorchEnd && HorizontalCount < HorzTimeToDisplayEnd)
        ADDRH <= HorizontalCount - 144;
      else
        ADDRH <= 0;
    end
    
    always@(posedge CLK) begin 
      if(VerticalCount > VertTimeToBackPorchEnd && VerticalCount < VertTimeToDisplayEnd)
        ADDRV <= VerticalCount - 31;
      else 
        ADDRV <= 0;
    end
    
endmodule
