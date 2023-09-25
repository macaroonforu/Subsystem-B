onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rxtx/MCLK
add wave -noupdate /tb_rxtx/next_lrclk_fall
add wave -noupdate /tb_rxtx/next_lrclk_rise
add wave -noupdate /tb_rxtx/next_sclk_fall
add wave -noupdate /tb_rxtx/next_sclk_rise
add wave -noupdate /tb_rxtx/i_sdata
add wave -noupdate -format Analog-Step -height 74 -max 65234.0 -min 101.0 -radix hexadecimal -label osc_output /tb_rxtx/dut/oscillator/o_sig_data
add wave -noupdate -radix hexadecimal -label dc_in_r /tb_rxtx/rdata
add wave -noupdate -format Analog-Step -height 74 -max 8388607.0 -radix hexadecimal -label consumer_out_right /tb_rxtx/o_right
add wave -noupdate -radix hexadecimal -label dc_in_l /tb_rxtx/ldata
add wave -noupdate -format Analog-Step -height 74 -max 8388607.0 -radix hexadecimal -label dc_o_l /tb_rxtx/o_dc_left
add wave -noupdate -format Analog-Step -height 74 -max 8388607.0 -radix hexadecimal -label consumer_out_left /tb_rxtx/o_left
add wave -noupdate -radix hexadecimal -label dc_o_r /tb_rxtx/o_dc_right
add wave -noupdate /tb_rxtx/consumer/mclk
add wave -noupdate /tb_rxtx/consumer/sclk
add wave -noupdate /tb_rxtx/consumer/lrclk
add wave -noupdate /tb_rxtx/consumer/i_sdata
add wave -noupdate /tb_rxtx/consumer/next_lrclk_fall
add wave -noupdate /tb_rxtx/consumer/next_lrclk_rise
add wave -noupdate /tb_rxtx/consumer/next_sclk_fall
add wave -noupdate /tb_rxtx/consumer/next_sclk_rise
add wave -noupdate /tb_rxtx/consumer/reset
add wave -noupdate /tb_rxtx/consumer/shift_enable
add wave -noupdate /tb_rxtx/consumer/counter_32
add wave -noupdate /tb_rxtx/consumer/temp_left
add wave -noupdate /tb_rxtx/consumer/temp_right
add wave -noupdate /tb_rxtx/consumer/count
add wave -noupdate /tb_rxtx/consumer/temp
add wave -noupdate /tb_rxtx/SCLK
add wave -noupdate /tb_rxtx/LRCLK
add wave -noupdate /tb_rxtx/reset
add wave -noupdate /tb_rxtx/o_sdout
add wave -noupdate /tb_rxtx/dut/oscillator/mclk
add wave -noupdate /tb_rxtx/dut/oscillator/reset
add wave -noupdate /tb_rxtx/dut/oscillator/en
add wave -noupdate /tb_rxtx/dut/oscillator/counter
add wave -noupdate /tb_rxtx/l_golden
add wave -noupdate /tb_rxtx/r_golden
add wave -noupdate /tb_rxtx/fail
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11284711 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 238
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {590277188 ps}
