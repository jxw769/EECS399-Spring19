# Tcl script for serial communicaiton between AD9913 and De1-SoC

set dash [add_service dashboard dashboard_example "AD9913" "Tools/Example"]
dashboard_set_property $dash self visible true

set parent "self"
dashboard_add $dash my_label label $parent
dashboard_set_property $dash my_label text "Please enter the output frequency (MHz): "
dashboard_set_property $dash self itemsPerRow 6

dashboard_add $dash my_text_field textField $parent
dashboard_set_property $dash my_text_field expandableX true

proc update_my_label_with_my_text_field {dash} {
	# Get the list of avalon memory map master services
	set masters [get_service_paths master]
	
	# Select the first master (the JTAG to avalon master)
	set master [lindex $masters 0]
	
	# Open the master service
	open_service master $master
	
	set f_out [dashboard_get_property $dash my_text_field text]
	puts "Entered Frequency: $f_out MHz"
	
	# Set addresses
	set start_addr 0x50
	set start_16_addr 0x00
	set oper_addr 0x40
	set done_addr 0x30
	set addr_addr 0x80
		# 4bit address
	set wr_data_addr 0x70
		# 32bit data
	set wr_data_16_addr 0x10
		# 16bit data
	set m_reset_addr 0x20
	
	# Set values
	set OPER 0
	
	set ADDR_00 0x00
	set WR_DATA_00 0x00
	
	set ADDR_01 0x01
	set WR_DATA_01 0x1452
	set WR_DATA_01_16 0x1452
		#16 bit
		
	set ADDR_02 0x02
	set WR_DATA_02 0x7F11FF
	
	set ADDR_03_FTW 0x03
		# @80MHz max
		# Need to be configured on-fly
		# 		FTW = round(2^32*(f_out/f_sysclk))
	set WR_DATA_03_FTW [expr {round($f_out / 250.0 * 4294967296)} ]
	puts "FTW (dec): $WR_DATA_03_FTW"
	set WR_DATA_03_FTW_HEX [format %x $WR_DATA_03_FTW]	
	puts "FTW (hex): $WR_DATA_03_FTW_HEX"
		#START and Power down control
	
	# Writing actions
	# Master reset before all actions
	master_write_8 $master $m_reset_addr 1
	master_write_8 $master $m_reset_addr 0
	after 10
	
	master_write_8 $master $addr_addr $ADDR_01
	master_write_32 $master $wr_data_16_addr $WR_DATA_01_16
	master_write_8 $master $oper_addr $OPER
	master_write_8 $master $start_addr 1
	master_write_8 $master $start_addr 0
	after 1
	
	master_write_8 $master $addr_addr $ADDR_00
	master_write_32 $master $wr_data_addr $WR_DATA_00
	master_write_8 $master $oper_addr $OPER
	master_write_8 $master $start_addr 1
	master_write_8 $master $start_addr 0
	after 1	
		# delay of 1ms
	
	master_write_8 $master $addr_addr $ADDR_02
	master_write_32 $master $wr_data_addr $WR_DATA_02
	master_write_8 $master $oper_addr $OPER
	master_write_8 $master $start_addr 1
	master_write_8 $master $start_addr 0
	after 10
	
	master_write_8 $master $addr_addr $ADDR_03_FTW
	master_write_32 $master $wr_data_addr $WR_DATA_03_FTW
	master_write_8 $master $oper_addr $OPER
	master_write_8 $master $start_addr 1
	master_write_8 $master $start_addr 0
	after 1
	
	puts "Write Done"
	
	# Close the master service
	close_service master $master
}

proc update_my_label_with_my_text_field_OFF {dash} {
	# Get the list of avalon memory map master services
	set masters [get_service_paths master]
	
	# Select the first master (the JTAG to avalon master)
	set master [lindex $masters 0]
	
	# Open the master service
	open_service master $master
	
	# Set addresses
	set start_addr 0x50
	set start_16_addr 0x00
	set oper_addr 0x40
	set done_addr 0x30
	set addr_addr 0x80
		# 4bit address
	set wr_data_addr 0x70
		# 32bit data
	set wr_data_16_addr 0x10
		# 16bit data
	set m_reset_addr 0x20
	
	# Set values
	set OPER 0
	
	set ADDR_00 0x00
	set WR_DATA_00 0x00
	
	set ADDR_01 0x01
	set WR_DATA_01 0x00
	set WR_DATA_01_16 0x00
		#16 bit
		
	set ADDR_02 0x02
	set WR_DATA_02 0x00
	
	set ADDR_03_FTW 0x03
	set WR_DATA_03_FTW 0x00
	
	master_write_8 $master $m_reset_addr 1
	master_write_8 $master $m_reset_addr 0
	after 10
	
	master_write_8 $master $addr_addr $ADDR_01
	master_write_32 $master $wr_data_16_addr $WR_DATA_01_16
	master_write_8 $master $oper_addr $OPER
	master_write_8 $master $start_addr 1
	master_write_8 $master $start_addr 0
	after 1
	
	master_write_8 $master $addr_addr $ADDR_00
	master_write_32 $master $wr_data_addr $WR_DATA_00
	master_write_8 $master $oper_addr $OPER
	master_write_8 $master $start_addr 1
	master_write_8 $master $start_addr 0
	after 1	
	
	master_write_8 $master $addr_addr $ADDR_02
	master_write_32 $master $wr_data_addr $WR_DATA_02
	master_write_8 $master $oper_addr $OPER
	master_write_8 $master $start_addr 1
	master_write_8 $master $start_addr 0
	after 10
	
	master_write_8 $master $addr_addr $ADDR_03_FTW
	master_write_32 $master $wr_data_addr $WR_DATA_03_FTW
	master_write_8 $master $oper_addr $OPER
	master_write_8 $master $start_addr 1
	master_write_8 $master $start_addr 0
	after 1
	
	puts "Session Stopped"
	
	# Close the master service
	close_service master $master
}

dashboard_add $dash my_button button self
dashboard_set_property $dash my_button text "Load"
dashboard_set_property $dash my_button onClick "update_my_label_with_my_text_field $dash"

dashboard_add $dash my_button1 button self
dashboard_set_property $dash my_button1 text "Stop"
dashboard_set_property $dash my_button1 onClick "update_my_label_with_my_text_field_OFF $dash"

dashboard_add $dash my_label_1 label $parent
dashboard_set_property $dash my_label_1 text "MAX: 80.000000000MHz"

dashboard_add $dash my_label_empty2 label $parent
dashboard_set_property $dash my_label_empty2 text "                    "

