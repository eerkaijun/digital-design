`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.11.2019 10:34:23
// Design Name: 
// Module Name: Top_wrapper
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


module Top_wrapper(
    input CLK,
    input RESET,
    input BTNU,
    input BTND,
    input BTNL,
    input BTNR,
    output [11:0] COLOUR_OUT,
    output HS,
    output VS,
    output [3:0] SEG_SELECT,
    output [7:0] HEX_OUT
    );
    
    wire [1:0] STATE;
    wire [1:0] DIRECTION;
    wire [9:0] ADDRH;
    wire [8:0] ADDRV;
    wire [7:0] RAND_ADDRH;
    wire [6:0] RAND_ADDRV;
    wire [11:0] COLOUR_INPUT;
    wire WIN;
    wire REACHED;
    wire TRIG;
    
    Master_state_machine MSM (
      .CLK(CLK),
      .RESET(RESET),
      .BTNU(BTNU),
      .BTND(BTND),
      .BTNL(BTNL),
      .BTNR(BTNR),
      .WIN(WIN),
      .TRIG(TRIG),
      .STATE(STATE)
    );
    
    Navigation_state_machine NSM (
      .CLK(CLK),
      .RESET(RESET),
      .BTNU(BTNU),
      .BTND(BTND),
      .BTNL(BTNL),
      .BTNR(BTNR),
      .DIRECTION(DIRECTION)  
    );
    
    Snake_controller #(
      .SnakeLength(20),
      .MaxX(159),
      .MaxY(119)   
      )
      Snake (
      .CLK(CLK),
      .RESET(RESET),
      .DIRECTION(DIRECTION),
      .ADDRH(ADDRH),
      .ADDRV(ADDRV),
      .RAND_ADDRH(RAND_ADDRH),
      .RAND_ADDRV(RAND_ADDRV),
      .MASTER_STATE(STATE),
      .COLOUR_OUT(COLOUR_INPUT),
      .REACHED(REACHED)
      );
    
    Target_generator Target (
      .CLK(CLK),
      .REACHED(REACHED),
      .TRIG(TRIG),
      .MASTER_STATE(STATE),
      .RAND_ADDRH(RAND_ADDRH),
      .RAND_ADDRV(RAND_ADDRV)
    );
    
    VGA_Wrapper VGA (
      .CLK(CLK),
      .COLOUR_INPUT(COLOUR_INPUT),
      .MASTER_STATE(STATE),
      .ADDRH(ADDRH),
      .ADDRV(ADDRV),
      .COLOUR_OUT(COLOUR_OUT),
      .HS(HS),
      .VS(VS)
    );
    
    Score_counter Score (
      .CLK(CLK),
      .RESET(RESET),
      .REACHED(REACHED),
      .WIN(WIN),
      .SEG_SELECT(SEG_SELECT),
      .HEX_OUT(HEX_OUT)
    );
    
endmodule


