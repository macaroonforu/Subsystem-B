
module mult #(
    parameter A_DATA_W = 16,
    parameter B_DATA_W = 24
) 
(
    /*
        This module contains signals used for pipelining (ready/valid). 

        The only signal to worry about is o_valid which is set to the logic value
        of delayed_i_valid. 
        
        delayed_i_valid should be asserted when the output of your 
        module is finished computing and is ready at the output.
    */
    input logic clk, //Use MCLK 
    input logic reset,

    input logic i_valid,   //Means that the previous module has data that can now be procesed 
    input logic i_ready,  //Means that a downstream module is ready for new input 

    input logic signed [A_DATA_W-1:0] i_a,
    input logic signed [B_DATA_W-1:0] i_b,
    
    output logic signed [B_DATA_W-1:0] o_c, // signed so output datawidth should be [DATA_WIDTH-1+1:0]
    output logic o_valid,  //the output is valid
    output logic o_ready  //this module is ready to receive a new input
);
    // This should be asserted when your modules output data is ready.
    // There is only a single delayed valid signal in this case as the computation is expected to
    // take a single cycle, for a multi cycle module which takes X cycles the o_valid needs to be delayed X cycles
    logic delayed_i_valid;
    assign o_valid = delayed_i_valid;
    assign o_ready = i_ready;
	logic enable; 
    logic signed [(A_DATA_W+B_DATA_W)-1:0]temp;
 
	assign enable = i_ready && i_valid; 
    always @ (posedge clk) begin 
       if(reset) begin 
            temp = 0; 
            delayed_i_valid = 1'b0; 
        end
    
	if(enable) begin 
		temp = (i_a * i_b);	
		delayed_i_valid = 1'b1;
 
		/*if(temp[(A_DATA_W+B_DATA_W)-1])
		begin
		     o_c[(A_DATA_W+B_DATA_W)-1:24] = 1'b1;
		end
		else
		begin
		     o_c[(A_DATA_W+B_DATA_W)-1:24] = 1'b0;
		end*/
        /*if (temp >= 40'h40_0000_0000) begin
            o_c = 24'h7ff_fff;
        end else*/
		o_c = temp[(A_DATA_W+B_DATA_W)-2 : 15];		
		end 
    else 
        delayed_i_valid = 1'b0;
	end
endmodule