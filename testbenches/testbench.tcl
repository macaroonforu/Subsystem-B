vlib work

vlog tb_downconverter.sv downconverter.sv sp_rom.sv osc.sv mult_unit_not_buffered.sv clockdiv.sv

vsim tb_downconverter

log {/*}

do wave.do

run -all
