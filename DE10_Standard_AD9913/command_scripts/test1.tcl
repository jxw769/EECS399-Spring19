# Get the list of avalon memory map master services
set masters [get_service_paths master]

# Select the first master (the JTAG to avalon master)
set master [lindex $masters 0]

# Open the master service
open_service master $master

# Set addresses
set start_addr 0x30
set oper_addr 0x20
set done_addr 0x10
set addr_addr 0x60
	# 4bit address
set wr_data_addr 0x50
	# 32bit data
set m_reset_addr 0x00

# Set values
set OPER 0

set ADDR_00 0x00
set WR_DATA_00 0x00

set ADDR_01 0x01
set WR_DATA_01 0x1452

set ADDR_02 0x02
set WR_DATA_02 0x7F11FF

set ADDR_03_FTW 0x03
#set WR_DATA_03_FTW 0x51EB851F 
	# @80MHz max
	# Need to be configured on-fly
	# 		FTW = round(2^32*(f_out/f_sysclk))
#puts "Enter output frequency (MHz): "
#flush stdout
#set f_out [gets stdin]
set f_out 80
puts $f_out
set WR_DATA_03_FTW [expr {round($f_out / 250.0 * 4294967296)} ]
puts $WR_DATA_03_FTW
	
	#!!!: NEED to add START and Power down control

# Writing actions
# Master reset before all actions
#master_write_8 $master $m_reset_addr 1
#master_write_8 $master $m_reset_addr 0
#after 1

master_write_8 $master $addr_addr $ADDR_00
master_write_32 $master $wr_data_addr $WR_DATA_00
master_write_8 $master $oper_addr $OPER
master_write_8 $master $start_addr 1
master_write_8 $master $start_addr 0
after 1	
	# delay of 1ms

master_write_8 $master $addr_addr $ADDR_01
master_write_32 $master $wr_data_addr $WR_DATA_01
master_write_8 $master $oper_addr $OPER
master_write_8 $master $start_addr 1
master_write_8 $master $start_addr 0
after 1

master_write_8 $master $addr_addr $ADDR_02
master_write_32 $master $wr_data_addr $WR_DATA_02
master_write_8 $master $oper_addr $OPER
master_write_8 $master $start_addr 1
master_write_8 $master $start_addr 0
after 1

master_write_8 $master $addr_addr $ADDR_03_FTW
master_write_32 $master $wr_data_addr $WR_DATA_03_FTW
master_write_8 $master $oper_addr $OPER
master_write_8 $master $start_addr 1
master_write_8 $master $start_addr 0
after 1

# Close the master service
close_service master $master