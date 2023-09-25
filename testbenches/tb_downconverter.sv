`timescale 1ns/1ps

module tb_downconverter ();

localparam MCLK_HALF_PERIOD = 20;
localparam DATA_RES = 24;
localparam NUM_FRAMES = 80;

logic MCLK;

logic next_lrclk_fall;
logic next_lrclk_rise;
logic next_sclk_fall;
logic next_sclk_rise;

logic SCLK;
logic LRCLK;

logic reset;

logic i_ready, i_valid, o_ready, o_valid;

logic signed [40-1:0] o_converted;
logic signed [23:0] data_in;

// 25 MHz Clock
always begin
    MCLK = 'b1;
    #(MCLK_HALF_PERIOD);
    MCLK = 'b0;
    #(MCLK_HALF_PERIOD);
end

// clock divider
clockdiv clock_div(
    .reset(reset),
    .MCLK(MCLK),
    .SCLK(SCLK),
    .LRCLK(LRCLK),
    // In this example the clock divider generates the previously mentioned optional control signals
    .next_lrclk_fall(next_lrclk_fall),
    .next_lrclk_rise(next_lrclk_rise),
    .next_sclk_fall(next_sclk_fall),
    .next_sclk_rise(next_sclk_rise)
);

downconverter dut (
    .i_signal(data_in),
    .mclk(MCLK),
    .sclk(SCLK),
    .reset(reset),
    .i_ready(next_lrclk_fall),
    .i_valid(next_lrclk_fall),
    .o_converted(o_converted),
    .o_ready(o_ready),
    .o_valid(o_valid)
);

initial begin
    reset = 1'b1;
    @(posedge MCLK);
    @(negedge MCLK);
    reset = 1'b0;

    data_in = 1'b0;

    @(posedge LRCLK);
    @(negedge LRCLK);
    data_in = 1'b1;

    for (int i = 0; i < NUM_FRAMES; i = i + 1) begin
        //delay
        @(posedge LRCLK);
        @(negedge LRCLK);
    end

    $stop(0);
end



endmodule