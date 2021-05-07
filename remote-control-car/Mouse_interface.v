`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: School of Engineering, University of Edinburgh
// Engineer: Yijun Cheng
// Create Date: 2021/02/25 16:35:03
// Design Name: DSL_4_Mouse_Interface_assignment_1
// Module Name: Timer
// Project Name: Mouse Interface
// Target Devices: Xilinx Basys 3
// Tool Versions: Xilinx Vivado 2015.2
// Description: connect mouse interface to data bus
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mouse_interface(
    //Standard Inputs  
    input RESET,  
    input CLK,  
    //Bus signals
    input [7:0] BUS_ADDR,
    inout [7:0] BUS_DATA, 
    //IO - Mouse side  
    inout CLK_MOUSE,   
    inout DATA_MOUSE, 
    //Interrupt Signals
    output BUS_INTERRUPT_RAISE,  
    input BUS_INTERRUPT_ACK 
    );
    

    wire Mouse_interrupt;
    wire  [7:0] MouseStatus;              
    wire  [7:0] MouseX;      
    wire  [7:0] MouseY;
   
    MouseTransceiver Mouse(
        //Standard Inputs  
        .RESET(RESET),  
        .CLK(CLK),  
        //IO - Mouse side  
        .CLK_MOUSE(CLK_MOUSE),   
        .DATA_MOUSE(DATA_MOUSE),               
        // Mouse data information               
        .MouseStatus(MouseStatus),               
        .MouseX(MouseX),      
        .MouseY(MouseY),
        .SendInterrupt(Mouse_interrupt)
        );
      
   
    //Address parameters
    parameter [7:0] MouseBaseAddr = 8'hA0; // MOUSE Base Address in the Memory Map
    reg Interrupt;
    //interrupt
    always@(posedge CLK) begin   
        if(RESET)    
            Interrupt <= 1'b0;   
        else if(Mouse_interrupt)    
            Interrupt <= 1'b1;   
        else if(BUS_INTERRUPT_ACK)    
            Interrupt <= 1'b0;  
    end    
    reg [7:0] Out;
    reg MouseBusWE;
    assign BUS_DATA = (MouseBusWE) ? Out : 8'hZZ; //only Output data to bus when mouse element is selected
    // write data to bus
    always@(posedge CLK) begin   
        if(BUS_ADDR == MouseBaseAddr)begin//MouseX
            Out <= MouseX;
            MouseBusWE <= 1'b1;                   
        end
        else if(BUS_ADDR == MouseBaseAddr + 8'h01)begin //MouseX
            Out <= MouseY;   
            MouseBusWE <= 1'b1;                   
        end
        else if(BUS_ADDR == MouseBaseAddr + 8'h02)begin//MouseStatus
            Out <= MouseStatus; 
            MouseBusWE <= 1'b1;                   
        end
        else
             MouseBusWE <= 1'b0; 
    end    
    //assign interrupt
    assign BUS_INTERRUPT_RAISE = Interrupt;
    
endmodule


