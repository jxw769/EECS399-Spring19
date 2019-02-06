onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider System_Signals
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/CLK
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/RESET
add wave -noupdate -divider Control_Signals
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/START
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/OPER
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/DONE
add wave -noupdate -divider Data_Signals
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/ADDR
add wave -noupdate -radix hexadecimal /TF_SPI_Bus_Transceiver/uut1/WR_DATA
add wave -noupdate -radix hexadecimal /TF_SPI_Bus_Transceiver/uut1/WR_DATA_16
add wave -noupdate -divider SPI_Bus_Signals
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/SPI_CS_N
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/SPI_SCLK
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/SPI_SDO
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/SPI_IO_UPDATE
add wave -noupdate -divider Internal_Signals_Bus_Timing
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/bus_rate_timer_reset
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/timer_count_reg
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/timer_tick
add wave -noupdate -divider Internal_Signals_Shift_Register_Actions
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/shift_reg_tx
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/shift_reg_tx_16
add wave -noupdate -radix decimal /TF_SPI_Bus_Transceiver/uut1/bit_count
add wave -noupdate -radix decimal /TF_SPI_Bus_Transceiver/uut1/byte_count
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/op_rw
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/op_addr
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/bit_count_done
add wave -noupdate /TF_SPI_Bus_Transceiver/uut1/byte_count_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 188
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {600 us}
run 600 us