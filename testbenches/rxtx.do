vlib work

vlog tb_rxtx.sv ../clockdiv.sv ../i2s_rx.sv ../i2s_tx.sv ../downconverter.sv ../mult_unit.sv ../osc.sv ../sp_rom.sv

vsim tb_rxtx

log {/*}

do wave1.do

run -all