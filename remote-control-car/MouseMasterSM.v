`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: School of Engineering, University of Edinburgh
// Engineer: Yijun Cheng
// 
// Create Date: 2021/01/18 00:49:09
// Design Name: DSL_4_Mouse_Interface_assignment_1
// Module Name: MouseMasterSM
// Project Name: Mouse Interface
// Target Devices: Xilinx Basys 3
// Tool Versions: Xilinx Vivado 2015.2
// Description: 
// 1) The host sends a Reset Command (consisting of byte "FF") to the mouse,
// 2) The mouse responds with an Acknowledgement byte "FA",
// 3) The mouse then goes through a self-test process and sends "AA" when this is passed.
// Then a mouse ID byte "00" is sent to the host, after which the host knows that the mouse
// is functioning well and ready to transmit data,
// 4) The host sends byte "F4" to instruct the mouse to "Start Transmitting" its position
// information,
// 5) The mouse acknowledges the "Start Transmitting" command by sending byte "FA" back
// to the host, but we receive F4 here and skip the parity bit check
// 6) After this, the mouse starts transmitting its position information in the form of 3 bytes at
// a sample rate that can be set by the host (the default is 100Hz)
// Dependencies: NA
// 
// Revision: 2.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MouseMasterSM(
    input CLK,
    input RESET,
    //Transmitter Control
    output SEND_BYTE,
    output [7:0] BYTE_TO_SEND,
    input BYTE_SENT,
    //Receiver Control
    output READ_ENABLE,
    input [7:0] BYTE_READ,
    input [1:0] BYTE_ERROR_CODE,
    input BYTE_READY,
    //Data Registers
    output [7:0] MOUSE_DX,
    output [7:0] MOUSE_DY,
    output [7:0] MOUSE_STATUS,
    //output reg  [3:0]   Curr_State,
    output SEND_INTERRUPT
//    output [3:0] currentstate  
    );
    
    /*--------------------------------------------------------------------------------------------|
    |    Main state machine - There is a setup sequence                                           |
    |                                                                                             |
    |    1) Send FF -- Reset command,                                                             |
    |    2) Read FA -- Mouse Acknowledge,                                                         |
    |    2) Read AA -- Self-Test pass                                                             |
    |    3) Read 00 -- Mouse ID                                                                   |
    |    4) Send F4 -- Start transmitting command,                                                |
    |    5) Read FA -- Mouse Acknowledge,                                                         |
    |---------------------------------------------------------------------------------------------*/
    
    //State Control
    reg   [3:0]   Curr_State,Next_State;
    reg   [23:0]  Curr_Counter,Next_Counter;
    //Transmitter Control
    reg           Curr_SendByte,Next_SendByte;
    reg   [7:0]   Curr_ByteToSend,Next_ByteToSend;
    //Receiver Control
    reg           Curr_ReadEnable,Next_ReadEnable;
    //Data Registers
    reg   [7:0]   Curr_Status,Next_Status;
    reg   [7:0]   Curr_Dx,Next_Dx;
    reg   [7:0]   Curr_Dy,Next_Dy;
    reg           Curr_SendInterrupt,Next_SendInterrupt;    
    
    //Sequential  
    always@(posedge CLK) begin   
        if(RESET) begin     
            Curr_State <= 4'h0;     
            Curr_Counter <= 0;     
            Curr_SendByte <= 1'b0;     
            Curr_ByteToSend <= 8'h00;     
            Curr_ReadEnable <= 1'b0;     
            Curr_Status  <= 8'h00;     
            Curr_Dx  <= 8'h00;     
            Curr_Dy  <= 8'h00;     
            Curr_SendInterrupt <= 1'b0;   
        end 
        else begin     
            Curr_State <= Next_State;     
            Curr_Counter <= Next_Counter;     
            Curr_SendByte <= Next_SendByte;     
            Curr_ByteToSend <= Next_ByteToSend;     
            Curr_ReadEnable <= Next_ReadEnable;     
            Curr_Status <= Next_Status;     
            Curr_Dx <= Next_Dx;     
            Curr_Dy <= Next_Dy;     
            Curr_SendInterrupt <= Next_SendInterrupt;   
        end  
    end     
    
    //Combinatorial  
    always@* begin   
        Next_State = Curr_State;   
        Next_Counter = Curr_Counter;   
        Next_SendByte = 1'b0;   
        Next_ByteToSend = Curr_ByteToSend;   
        Next_ReadEnable = 1'b0;   
        Next_Status = Curr_Status;   
        Next_Dx = Curr_Dx;   
        Next_Dy = Curr_Dy;   
        Next_SendInterrupt = 1'b0;   
       
        case(Curr_State)     
            //Initialise State 
            //Wait here for 10ms before trying to initialise the mouse.    
            4'h0:begin       
                if(Curr_Counter == 1000000) begin // 1/100th sec at 100MHz clock         
                    Next_State = 4'h1;         
                    Next_Counter = 0; 
                end 
                else         
                    Next_Counter = Curr_Counter + 1'b1;
            end    
            //Start initialisation by sending FF
            4'h1:begin
                Next_State = 4'h2;
                Next_SendByte = 1'b1;//enable Transmitter sendbyte
                Next_ByteToSend = 8'hFF;//Host send 'FF' to Mouse to initialization
            end    
            //Wait for confirmation of the byte being sent    
            4'h2:begin     
                if(BYTE_SENT) begin
                    Next_State = 4'h3;
                    Next_SendByte = 1'b0;//////////////////////////////////////////////////////////////////////////////////////
                end
            end    
            //Wait for confirmation of a byte being received
            //If the byte is FA goto next state, else re-initialise.    
            4'h3:begin  
                Next_ReadEnable = 1'b1;// Enable receiver                      
                if(BYTE_READY) begin         
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))//read FA and 00 for errorcode                                                           
                        Next_State = 4'h4;                                                        
                    else              
                        Next_State = 4'h0;// re-initialise                                                    
                end   
            end    
           //Wait for self-test pass confirmation    
           //If the byte received is AA goto next state, else re-initialise    
            4'h4:begin     
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hAA) & (BYTE_ERROR_CODE == 2'b00))                                                           
                        Next_State = 4'h5;                                                        
                    else           
                        Next_State = 4'h0;// Reinitialise                                                     
                end 
                Next_ReadEnable = 1'b1;// Enable receiver
            end    
           //Wait for confirmation of a byte being received     
           //If the byte is 00 goto next state (MOUSE ID) else re-initialise    
            4'h5:begin     
                if(BYTE_READY) begin         
                    if((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00))//read 00 and 00 for errorcode                                                           
                        Next_State = 4'h6;                                                        
                    else           
                        Next_State = 4'h0;// Reinitialise 
                end                         
                Next_ReadEnable = 1'b1;// Enable receiver             
            end    
            //Send F4 - to start mouse transmit    
            4'h6:begin       
                Next_State = 4'h7;       
                Next_SendByte = 1'b1;// Enable Transmitter      
                Next_ByteToSend = 8'hF4;//Send F4 from Host to Mouse to start its transmision     
            end    
            //Wait for confirmation of the byte being sent    
            4'h7:begin 
                if(BYTE_SENT) 
                    Next_State = 4'h8;
            end
            //Wait for confirmation of a byte being received    
            //If the byte is F4 goto next state, else re-initialise    
            4'h8:begin     
                if(BYTE_READY) begin         
                    if(BYTE_READ == 8'hF4)                                                           
                        Next_State = 4'h9;
                    else           
                        Next_State = 4'h0;// Reinitialise                                                      
                end 
                Next_ReadEnable = 1'b1; // Enable receiver            
            end   
            //-------------------------------------------------------//
            //At this point the SM has initialised the mouse.        //
            //Now we are constantly reading.  If at any time         //
            //there is an error, we will re-initialise               //
            //the mouse - just in case.                              // 
            //-------------------------------------------------------//        

            //Wait for the confirmation of a byte being received.    
            //This byte will be the first of three, the status byte.    
            //If a byte arrives, but is corrupted, then we re-initialise    

            4'h9:begin 
                if(BYTE_READY & (BYTE_ERROR_CODE == 2'b00)) begin
                    Next_State = 4'hA;              
                    Next_Status = BYTE_READ;// Read Status  
                end 
                Next_Counter = 0;              
                Next_ReadEnable = 1'b1;// Enable receiver
      
            end    
            //Wait for confirmation of a byte being received    
            //This byte will be the second of three, the Dx byte.    
             4'hA:begin
                if(BYTE_READY & (BYTE_ERROR_CODE == 2'b00)) begin
                     Next_State = 4'hB;              
                     Next_Dx = BYTE_READ;// Read Dx  
                 end 
                 Next_Counter = 0;              
                 Next_ReadEnable = 1'b1;// Enable receiver
         
            end 
                 
            //Wait for confirmation of a byte being received    
            //This byte will be the third of three, the Dy byte.    
            4'hB:begin
                if(BYTE_READY & (BYTE_ERROR_CODE == 2'b00)) begin
                    Next_State = 4'hC;              
                    Next_Dy = BYTE_READ;// Read Dy  
                end 
                Next_Counter = 0;              
                Next_ReadEnable = 1'b1;// Enable receiver                     
       
            end     
            //Send Interrupt State    
            4'hC:begin     
                Next_State = 4'h9;     
                Next_SendInterrupt = 1'b1;// Interrupt flag reg               
            end   
                    
            //Default State                 
            default:begin     
                Next_State   = 4'h0;     
                Next_Counter  = 0;     
                Next_SendByte  = 1'b0;     
                Next_ByteToSend  = 8'hFF;     
                Next_ReadEnable = 1'b0;     
                Next_Status   = 8'h00;     
                Next_Dx   = 8'h00;     
                Next_Dy   = 8'h00;     
                Next_SendInterrupt = 1'b0;         
            end   
        endcase  
    end    
    //----------------------------------------------------------------   
    //Transmitter  
    assign SEND_BYTE = Curr_SendByte; 
    assign BYTE_TO_SEND = Curr_ByteToSend; 
    
    //Receiver  
    assign READ_ENABLE = Curr_ReadEnable;   

    //Output Mouse Data  
    assign MOUSE_DX = Curr_Dx;  
    assign MOUSE_DY = Curr_Dy;  
    assign MOUSE_STATUS = Curr_Status;  
    assign SEND_INTERRUPT = Curr_SendInterrupt;
    
//    assign currentstate = Curr_State;    
    //------------------------------------------------------------------  
endmodule

