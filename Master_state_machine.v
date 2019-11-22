`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2019 09:58:55
// Design Name: 
// Module Name: Master_state_machine
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


module Master_state_machine(
    input CLK,
    input RESET,
    input BTNU,
    input BTND,
    input BTNL,
    input BTNR,
    input WIN,
    output reg TRIG,
    output [1:0] STATE
    );
    
    reg [1:0] Curr_state;
    reg [1:0] Next_state;
    
    assign STATE = Curr_state;
    
    //Sequential logic
    always@(posedge CLK) begin
      if (RESET)
        Curr_state <= 2'b00;
      else 
        Curr_state <= Next_state;
    end
    
    //Combinational logic
    always@(WIN or Curr_state or BTNU or BTND or BTNL or BTNR) begin
      case(Curr_state)
      
        2'b00: begin
          if (BTNU || BTND || BTNL || BTNR) begin
            Next_state <= 2'b01;
            TRIG <= 1;
          end
          else 
            Next_state <= Curr_state;
        end
        
        2'b01: begin
          if(WIN)
            Next_state <= 2'b10;
          else begin
            Next_state <= Curr_state;
            TRIG <= 0;
          end 
        end
        
        2'b10: begin
          Next_state <= Curr_state;
        end
        
        default: 
          Next_state <= 2'b00;
          
      endcase
    end
    
    
endmodule
