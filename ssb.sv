module ssb(i, q, h, d, clk, ena, next_lrclk_fall, rst, usb, ssb_out);
	parameter L = 24; 
	parameter M = 16; 
	parameter O = 41; //Calculated Gamma for Hilbert Filter, can also try 41 if 42 is not working
	//Hilbert filter has same accumulator wordlength as lpf 
	parameter DELAYS = 50; 
	input logic signed [23:0] i; //left channel
	input logic signed [23:0] q; //right channel (90 degree phase shift)
	input  logic signed [M-1:0]h[DELAYS:0]; 
	input  logic signed [M-1:0]d[DELAYS:0]; 
	input logic clk; 
	input logic ena; 
	input logic next_lrclk_fall; 
	input logic rst; 
	input logic usb; 
	output logic signed [23:0] ssb_out; 
	logic signed [23:0] delayed_i; 
	logic signed [23:0] hilberted_q;
   logic signed [24:0] add; 
   logic signed [24:0] sub; 	
	
	logic o_hilbert_valid;
//	logic signed [23:0] add_out; 
//	logic signed [23:0] sub_out; 

//Want an accumulator wordlength of only 24 bits, and to output bits 23:0, 
//Hence, A=24, and O = 24 for delay 

//left channel is i
//right channel is q

always@(next_lrclk_fall)begin
	delayed_i <= i; 
end 
initial begin 
	ssb_out = 24'b0; 
end 
/*
fir delay(
	.x_in(i), 
	.y_out(delayed_i), 
	.b(d), 
	.clk(clk), 
	.ena(1), 
	.next_lrclk_fall(next_lrclk_fall), 
	.rst(rst)
); 
*/
/*
fir #(.O(O)) hilbert(
	.x_in(q), 
	.y_out(hilberted_q), 
	.b(h), 
	.clk(clk), 
	.ena(1), 
	.next_lrclk_fall(next_lrclk_fall), 
	.rst(rst)
); 
*/
hilbert (
		.ast_sink_data(q),    //   avalon_streaming_sink.data
		.ast_sink_valid(next_lrclk_fall),   //                        .valid
		.ast_source_data(hilberted_q),  // avalon_streaming_source.data
		.ast_source_valid(o_hilbert_valid), //                        .valid
		.clk(clk),              //                     clk.clk
		.reset_n(!rst)           //                     rst.reset_n
	);

//delay reg
always @(o_hilbert_valid)begin 
	add = delayed_i + hilberted_q; 
	sub = delayed_i + (~hilberted_q + 1'b1); 
end 

always @(next_lrclk_fall) begin 
	if(!usb)begin 
		ssb_out = add[24:1]; //lsb is i + q
	end 
	else if (usb) begin 
		ssb_out = sub[24:1]; //usb is i - q
	end
end 

//I removed the adder and subtractor units and replaced it with above, and works the same in 
//ModelSim 
//adder a0(
//	.clk(clk), 
//   .reset(rst), 
//	.next_lrclk_fall(next_lrclk_fall),
//	.a(delayed_i), 
//   .b(hilberted_q), 
//	.o_c(add_out)
//); 
//
//subtractor s0(
//	.clk(clk), 
//   .reset(rst), 
//	.next_lrclk_fall(next_lrclk_fall),
//	.a(delayed_i), 
//   .b(hilberted_q), 
//	.o_c(sub_out)
//); 
//
//always @(*) begin 
//	if(usb)begin 
//		ssb_out = add_out; 
//	end 
//	else 
//		ssb_out = sub_out; 
//end 

endmodule 