`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2021 07:46:56 AM
// Design Name: 
// Module Name: TopLevel
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


module TopLevel(
    input CLK,
    input RESET,
    inout CLK_MOUSE,   
    inout DATA_MOUSE,
    output [3:0] SEG_SELECT_OUT,
    output [7:0] HEX_OUT,
    output [7:0] LED_out,
    output IR_LED
    );

    wire [7:0] BUS_DATA;
    wire [7:0] BUS_ADDR;
    wire [7:0] ROM_ADDRESS;
    wire [7:0] ROM_DATA;
    wire BUS_WE;
    wire [1:0] BUS_INTERRUPTS_ACK;
    wire [1:0] BUS_INTERRUPTS_RAISE;
    
    RAM ram (
      .CLK(CLK),
      .BUS_DATA(BUS_DATA),
      .BUS_ADDR(BUS_ADDR),
      .BUS_WE(BUS_WE)
    );  
    
    ROM rom (
      .CLK(CLK),
      .ADDR(ROM_ADDRESS),
      .DATA(ROM_DATA)
    );
    
    Processor controller (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_ADDR(BUS_ADDR),
      .BUS_DATA(BUS_DATA),
      .BUS_WE(BUS_WE),
      .ROM_ADDRESS(ROM_ADDRESS),
      .ROM_DATA(ROM_DATA),
      .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE),
      .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK)
    );
    
    Timer timer (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_ADDR(BUS_ADDR),
      .BUS_DATA(BUS_DATA),
      .BUS_WE(BUS_WE),
      .BUS_INTERRUPT_ACK(BUS_INTERRUPTS_ACK[1]),
      .BUS_INTERRUPT_RAISE(BUS_INTERRUPTS_RAISE[1])
    );
    
    IRTransmitter transmitter (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_ADDR(BUS_ADDR),
      .BUS_DATA(BUS_DATA),
      .BUS_WE(BUS_WE),
      .IR_LED(IR_LED)
    );
    
    Mouse_interface Mouse_interface(  
      .CLK(CLK),
      .RESET(RESET),  
      .BUS_DATA(BUS_DATA),
      .BUS_ADDR(BUS_ADDR),   
      .CLK_MOUSE(CLK_MOUSE),   
      .DATA_MOUSE(DATA_MOUSE), 
      .BUS_INTERRUPT_RAISE(BUS_INTERRUPTS_RAISE[0]),  
      .BUS_INTERRUPT_ACK(BUS_INTERRUPTS_ACK[0]) 
    );
    
    seg7decoder seg7(  
      .CLK(CLK),
      .BUS_DATA(BUS_DATA),
      .BUS_ADDR(BUS_ADDR),
      .SEG_SELECT_OUT(SEG_SELECT_OUT),
      .SEG7_OUT(HEX_OUT)
    );

    LED LED(
      .CLK(CLK),
      .BUS_DATA(BUS_DATA),
      .BUS_ADDR(BUS_ADDR), 
      .LED_out(LED_out)
    );    
    
endmodule
