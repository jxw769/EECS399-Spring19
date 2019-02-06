
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE1_SOC_AD9913(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
	
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

	//
	// System Parameters
	//
	localparam CLK_RATE_HZ = 50000000; // 50 MHZ
	localparam BUS_RATE_HZ = 500000; // 5 MHz
	
	wire 	START;
	wire 	OPER;
	wire 	DONE; 
	wire [4:0] 	ADDR; // Entire intruction byte. 7: R/(W_N), 5-0: address.
	wire [31:0] WR_DATA;
	//wire [31:0] RD_DATA;
	wire 	RESET;
	wire 	START_16;
	wire [15:0] WR_DATA_16;
	
	//parameter [(4*8)-1:0] DATA_LENGTH = {8'd16,8'd32,8'd48,8'd64};
	localparam DATA_LENGTH_16 = 16;
	localparam DATA_LENGTH_32 = 32;

//=======================================================
//  Structural coding
//=======================================================
	
   test1a u0 (
       .addr_external_connection_export    (ADDR),    	//    addr_external_connection.export
       .clk_clk                            (CLOCK_50),   //                         clk.clk
       .led_external_connection_export     (LEDR),     	//     led_external_connection.export
       .reset_reset_n                      (1'b1),       //                       reset.reset_n
       .wr_data_external_connection_export (WR_DATA), 	// wr_data_external_connection.export
       //.gpio_external_connection_export    (GPIO[35:0]), //    gpio_external_connection.export
       .start_external_connection_export   (START),  		//   start_external_connection.export
       .oper_external_connection_export    (OPER),    	//    oper_external_connection.export
       .done_external_connection_export    (DONE),     	//    done_external_connection.export
		 .m_reset_external_connection_export (RESET),  // m_reset_external_connection.export
		 .wr_data_16_external_connection_export (WR_DATA_16), // wr_data_16_external_connection.export
       .start_16_external_connection_export   (START_16)    //   start_16_external_connection.export
   );
	
	SPI_Bus_Transceiver
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.BUS_RATE_HZ( BUS_RATE_HZ ),
		.DATA_LENGTH_16( DATA_LENGTH_16 ),
		.DATA_LENGTH_32( DATA_LENGTH_32 )
	)
	spi_transceiver
	(
		// Control Signals
		.START( START ),  // Might need actual trigger length control like in 326.
		.OPER( OPER /*1'b0*/ ), // 0 WRITE, 1 READ
		.DONE( DONE ), // Asserted if the commmunication cycle is finished. 
		
		// Data Signals
		.ADDR( ADDR ),
		.WR_DATA( WR_DATA ), // NOTICE the variable data length for different reg address
		.WR_DATA_16( WR_DATA_16 ),
		//.RD_DATA(  ),  
			// !!! RD_DATA is unused, as data written into chip can be read from command console. 
				
		// SPI Bus Signals
		.SPI_CS_N( GPIO[13] ), // 13 oranges
		.SPI_SCLK( GPIO[17] ), // 17 browns
		.SPI_SDO( GPIO[15] ), // Connected to SDIO pin but only excecute WRITE action. 15 red 
		//.SPI_SDI( SPI_MISO ), // Unused if only WRITE action
		.SPI_IO_UPDATE( GPIO[11] ), // 11 yellow  
		
		// Vcc: GPIO_Pin11
		// GND: GPIO_Pin12
	
		// System Signals
		.CLK( CLOCK_50 ),
		.RESET( 1'b0 )
	);

	assign GPIO[19] = RESET;
	
endmodule
