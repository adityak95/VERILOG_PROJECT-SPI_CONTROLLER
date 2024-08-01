vlib work 
vlog tb_spi.v
vsim tb	+size=half_starting_from_4 
#add wave -position insertpoint sim:/tb/dut/*
do wave.do
run -all
