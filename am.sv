`timescale 1ns / 100ps
`default_nettype none

module am(i, q, b, clk, ena, next_lrclk_fall, rst, i_out, q_out);
	parameter L = 24; 
	parameter M = 16; 
	parameter DELAYS = 40; 
	input logic signed [23:0] i; //left channel
	input logic signed [23:0] q; //right channel
	input  logic signed [M-1:0]b[DELAYS:0];   
	input logic clk; 
	input logic ena; 
	input logic next_lrclk_fall; 
	input logic rst; 
	output logic signed [23:0] i_out; 
	output logic signed [23:0] q_out; 

	logic signed [23:0] i_filt, q_filt;

/*	
fir #(.DELAYS(DELAYS)) left(
	.x_in(i), 
	.y_out(i_out), 
	.b(b), 
	.clk(clk), 
	.ena(1), 
	.next_lrclk_fall(next_lrclk_fall), 
	.rst(rst)
); 


fir #(.DELAYS(DELAYS)) right(
	.x_in(q), 
	.y_out(q_out), 
	.b(b), 
	.clk(clk), 
	.ena(1), 
	.next_lrclk_fall(next_lrclk_fall), 
	.rst(rst)
); 
*/

test left(
		.ast_sink_data(i),    //   avalon_streaming_sink.data
		.ast_sink_valid(next_lrclk_fall),   //                        .valid
	
		.ast_source_data(i_filt),  // avalon_streaming_source.data


		.clk(clk),              //                     clk.clk
		.reset_n(!rst)           //                     rst.reset_n
	);

test right(
		.ast_sink_data(q),    //   avalon_streaming_sink.data
		.ast_sink_valid(next_lrclk_fall),   //                        .valid
	
		.ast_source_data(q_filt),  // avalon_streaming_source.data


		.clk(clk),              //                     clk.clk
		.reset_n(!rst)           //                     rst.reset_n
	);

always@(next_lrclk_fall) begin
	i_out <= i_filt;
	q_out <= q_filt;
end

endmodule 




