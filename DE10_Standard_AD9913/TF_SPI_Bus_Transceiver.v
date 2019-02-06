`timescale 1ns / 1ps

module TF_SPI_Bus_Transceiver;

	localparam BUS_RATE_HZ = 5000000;   // 1 MHz
	localparam DATA_LENGTH_32 = 32;        // 32-bit length
	localparam DATA_LENGTH_16 = 16;        // 32-bit length

	//
	// System Clock Emulation
	//
	localparam CLK_RATE_HZ = 50000000; // 50 MHz
	localparam CLK_HALF_PER = ((1.0 / CLK_RATE_HZ) * 1000000000.0) / 2.0; // ns
	reg        CLK;
	
	initial
	begin
		CLK = 1'b0;
		forever #(CLK_HALF_PER) CLK = ~CLK;
	end

	//
	// Unit Under Test: SPI_Bus_Transceiver
	//
	reg 	START;
	reg 	OPER;
	wire 	DONE;
		
	reg [4:0]					ADDR;
	reg [(DATA_LENGTH_32-1):0]	WR_DATA;
	//wire [(DATA_LENGTH-1):0]	RD_DATA;
	reg [(DATA_LENGTH_16-1):0]	WR_DATA_16;
	
	wire 	SPI_SCLK;
	wire 	SPI_SDO;
	//wire SPI_SDI;
	wire 	SPI_CS_N;
	wire 	SPI_IO_UPDATE;

	reg  	RESET;

	SPI_Bus_Transceiver
	#(
		.CLK_RATE_HZ( CLK_RATE_HZ ),
		.BUS_RATE_HZ( BUS_RATE_HZ ),
		.DATA_LENGTH_16( 16 ),
		.DATA_LENGTH_32( 32 )
	)
	uut1
	(
		// Control Signals
		.START( START ),
		.OPER( OPER ),
		.DONE( DONE ),

		// Data Signals
		.ADDR( ADDR ),
		.WR_DATA( WR_DATA ),
		//.RD_DATA( RD_DATA ),
		.WR_DATA_16( WR_DATA_16 ),
		
		// SPI Bus Signals
		.SPI_CS_N( SPI_CS_N ),
		.SPI_SCLK( SPI_SCLK ),
		.SPI_SDO( SPI_SDO ),
		//.SPI_SDI( SPI_SDI ),
		.SPI_IO_UPDATE( SPI_IO_UPDATE ),

		// System Signals
		.CLK( CLK ),
		.RESET( RESET )
	);


	//
	// Test Sequence
	//
	initial
	begin
	
		// Initialize Signals
		RESET = 1'b1;
		#500;
		RESET = 1'b0;
		#500;
		
		OPER = 1'b0;
		//ADDR = 5'h03; // Reg Addr h03
		//WR_DATA = 32'd1; // 
		
		// Default Reg Values
		/*
			00: 00 00 00 00
			01: 14 53 (bin: 00010100 01010011, CFR2[0] is 1 when PLL is locked)
			02: 00 7F 11 FF (bin: 0000000 01111111 00010001 11111111)
			03(FTW=80MHz): 51 EB 85 1F (bin: 01010001 11101011 10000101 00011111)
		*/
		// Start data transfer
		ADDR = 5'h00;
		WR_DATA = 32'd0;
		START = 1'b1;
		#100000;
		START	= 1'b0;
		#10
		
		ADDR = 5'h01;
		//WR_DATA = 32'h1453;
		WR_DATA_16 = 16'h1453;
		#50000;
		START = 1'b1;
		#100000;
		START	= 1'b0;
		#10
		
		ADDR = 5'h02;
		WR_DATA = 32'h007F11FF;
		#50000;
		START = 1'b1;
		#100000;
		START	= 1'b0;
		#10
		
		ADDR = 5'h03;
		WR_DATA = 32'h51EB851F;
		#50000;
		START = 1'b1;
		#100000;
		START	= 1'b0;
		
	end

endmodule
