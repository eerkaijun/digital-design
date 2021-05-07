`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2019 10:06:10
// Design Name: 
// Module Name: Navigation_state_machine
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


module Navigation_state_machine(
    input CLK,
    input RESET,
    input BTNL,
    input BTNR,
    input BTNU,
    input BTND,
    output [1:0] DIRECTION
    );
    
    reg [1:0] Curr_state;
    reg [1:0] Next_state;
    
    assign DIRECTION = Curr_state;
    
    //Sequential logic
    always@(posedge CLK) begin
      if (RESET)
        Curr_state <= 2'b00;
      else 
        Curr_state <= Next_state;
    end
       
    //Combinational logic
    always@(BTNL or BTNR or BTNU or BTND or Curr_state) begin
      case(Curr_state)
      
        //Direction Up
        2'b00: begin
          if (BTNL)
            Next_state <= 2'b10;
          else if (BTNR)
            Next_state <= 2'b11;
          else 
            Next_state <= Curr_state;
        end
        
        //Direction Down
        2'b01: begin
          if (BTNL)
            Next_state <= 2'b10;
          else if (BTNR)
            Next_state <= 2'b11;
          else 
            Next_state <= Curr_state;
        end
        
        //Direction Left
        2'b10: begin
          if (BTNU)
            Next_state <= 2'b00;
          else if (BTND)
            Next_state <= 2'b01;
          else 
            Next_state <= Curr_state;
        end
        
        //Direction Right
        2'b11: begin
          if (BTNU)
            Next_state <= 2'b00;
          else if (BTND)
            Next_state <= 2'b01;
          else 
            Next_state <= Curr_state;
        end
      
      endcase
    end
     
endmodule
