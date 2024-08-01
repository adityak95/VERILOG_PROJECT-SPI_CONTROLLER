onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/dut/pclk
add wave -noupdate /tb/dut/prst
add wave -noupdate /tb/dut/penable
add wave -noupdate -radix unsigned /tb/dut/paddr
add wave -noupdate -radix hexadecimal /tb/dut/pwdata
add wave -noupdate /tb/dut/pwr_rd
add wave -noupdate /tb/dut/sclk_ref
add wave -noupdate /tb/dut/miso
add wave -noupdate -radix hexadecimal /tb/dut/prdata
add wave -noupdate /tb/dut/pready
add wave -noupdate /tb/dut/mosi
add wave -noupdate /tb/dut/sclk
add wave -noupdate /tb/dut/cs
add wave -noupdate /tb/dut/ctrl_reg
add wave -noupdate /tb/dut/present_state
add wave -noupdate /tb/dut/next_state
add wave -noupdate /tb/dut/i
add wave -noupdate /tb/dut/count
add wave -noupdate /tb/dut/num_txn_pending
add wave -noupdate /tb/dut/current_txn_index
add wave -noupdate /tb/dut/data_rxn
add wave -noupdate /tb/dut/data_txn
add wave -noupdate /tb/dut/addr_txn
add wave -noupdate /tb/dut/sclk_running_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {3341628 ps}
