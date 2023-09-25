`timescale 1ns/1ps

module subtractor(clk, reset, next_lrclk_fall, a, b, o_c); 
    parameter L = 24; 
    input logic clk; 
    input logic reset; 
	 input logic next_lrclk_fall;   
    input logic signed [L-1:0] a; 
    input logic signed [L-1:0] b; 
    output logic signed [L-1:0] o_c; 

//Take in a and b on LRCLK falling edge 
logic signed [L-1:0] a_in;
logic signed [L-1:0] b_in;
logic signed [L:0] sum; 

async_reg #(.L(L)) SYNCHRONIZER_A_IN(
    .clk(clk),
    .ena(next_lrclk_fall),//if we change this to be just ena, there is noise like crazy!!
    .rst(reset),
    .d(a),
    .q(a_in)
);

async_reg #(.L(L)) SYNCHRONIZER_B_IN(
    .clk(clk),
    .ena(next_lrclk_fall),//if we change this to be just ena, there is noise like crazy!!
    .rst(reset),
    .d(b),
    .q(b_in)
);

always_comb begin : output_logic
   sum = a_in - b_in;  // combinational logic 
end

always@(next_lrclk_fall)begin 
	o_c <= sum[(L-1):0];  
end  

endmodule

