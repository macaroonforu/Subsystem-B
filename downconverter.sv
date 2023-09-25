module downconverter #(
    DATA_WIDTH = 24,
    DOUT_W = 16,
    MULT_W = 40
) (
    input logic signed [DATA_WIDTH-1:0] i_signal_left,
    input logic signed [DATA_WIDTH-1:0] i_signal_right,
    input logic mclk,
    input logic reset,
    input logic i_ready,
    input logic i_valid,
    input logic next_lrclk_fall,
    output logic signed [DATA_WIDTH-1:0] o_converted_left,
    output logic signed [DATA_WIDTH-1:0] o_converted_right,
    output logic o_ready,
    output logic o_valid
);

logic signed [DOUT_W-1:0] osc_out;
logic enable;
logic signed [DATA_WIDTH-1:0] o_mixer_left, o_mixer_right;

assign enable = i_valid;


//oscillator outputs a new value every LRCLK frame
osc oscillator(
    .mclk(mclk),
    .reset(reset),
    .en(enable), 
    .o_sig_data(osc_out)
);

mult mixer_l(
    .clk(mclk), //Use MCLK 
    .reset(reset),

    .i_valid(i_valid),   //Means that the previous module has data that can now be procesed 
    .i_ready(i_ready),  //Means that a downstream module is ready for new input 

    .i_a(osc_out), //16 bits
    .i_b(i_signal_left), //24 bits
    
    .o_c(o_mixer_left), // signed so output datawidth should be [DATA_WIDTH-1+1:0]
    
    .o_valid(o_valid),  //the output is valid
    .o_ready(o_ready)  //this module is ready to receive a new input
);

mult mixer_r(
    .clk(mclk), //Use MCLK 
    .reset(reset),

    .i_valid(i_valid),   //Means that the previous module has data that can now be procesed 
    .i_ready(i_ready),  //Means that a downstream module is ready for new input 

    .i_a(osc_out), //16 bits
    .i_b(i_signal_right), //24 bits
    
    .o_c(o_mixer_right), // signed so output datawidth should be [DATA_WIDTH-1+1:0]
    
    .o_valid(o_valid),  //the output is valid
    .o_ready(o_ready)  //this module is ready to receive a new input
);

always@(next_lrclk_fall)begin 
	o_converted_left <= o_mixer_left;
    o_converted_right <= o_mixer_right;
end  


endmodule