`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: School of Engineering, University of Edinburgh
// Engineer: YIJUN CHENG
// 
// Create Date: 27.10.2019 23:53:31
// Module Name: generic_counter
// Project Name: Mouse Interface
// Target Devices: Xilinx Basys 3
// Tool Versions: Xilinx Vivado 2015.2
// Description: This module works for encode the character
// Revision: 2.1
// Additional Comments: This is a module for counting numbers and output a trig signal
// when counting to maximum number.
//////////////////////////////////////////////////////////////////////////////////


module generic_counter(
    CLK,//clock signal
    RESET,//reset signal
    ENABLE,//signal to enable counting
    TRIG_OUT,//signal to indicate counting completion
    COUNT//the number we count
    );   
    parameter WIDTH = 10;
    parameter MAX = 800;
    input CLK;
    input RESET;
    input ENABLE;
    output  TRIG_OUT;
    output  [WIDTH-1:0] COUNT;    
    reg [WIDTH-1:0] count_value = 0;
    reg trig;
    //count numbers
    always@(posedge CLK) begin
        if (RESET)
            count_value <= 0;
        else begin
            if (ENABLE)begin           
                if(count_value == MAX)
                    count_value <= 0;
                else
                    count_value <= count_value + 1;
            end
        end
    end 
    //output trig signal  
    always@(posedge CLK)begin
        if (RESET)
            trig <= 0;
        else begin
            if (count_value == MAX && ENABLE)
                trig <= 1;
            else 
                trig <= 0;
        end
    end
    assign COUNT = count_value;
    assign TRIG_OUT = trig;
endmodule

