`timescale 1ns / 1ps

module SPI_Bus_Transceiver
#(
	parameter CLK_RATE_HZ = 50000000,  // Hz
	parameter BUS_RATE_HZ = 500000,  // Hz  // Need lower bus rate for testing purposes
	parameter DATA_LENGTH_16,
	parameter DATA_LENGTH_32
)
(
	// Control Signals
	input            	START,
		// Trigger output from System Console. 
	input      		 	OPER,
		// Determine R/W operaions (and burst read). Can be configured as a single switch
	output reg       	DONE,

	// Data Signals (IO from system console)
	input       [4:0] ADDR,
	// !!! NOTICE: WR_DATA might have variable byte length (2-8 bytes)
	// Possible Solution: set WR_DATA to maximum length (8 bytes) and only write needed length accordingly after
	// OR: a LUT for ADDR, then set reg WR_DATA length according to ADDR address
	// NOTICE limit on GPIO bit width, might still need write multiple registers
	input      [31:0] WR_DATA,
	
	input      [15:0] WR_DATA_16,
	
	// If READ is necessary, then direct out put shift register values from SDI input.
	//output reg  [(DATA_LENGTH-1):0] RD_DATA, 

	// SPI Bus Signals
	output reg SPI_CS_N,
	output reg SPI_SCLK,
	output reg SPI_SDO, //IP catalog: IO: ALTIOBUF: bidrectional buffer
	//input      SPI_SDI, // Not necessary if only WRITE
	output reg SPI_IO_UPDATE, //!!!NOTICE: IOUPDATE has to have larger pulse width than CLK.

	// System Signals
	input CLK,
	input RESET
);

	// Include StdFunctions for bit_index()
	`include "StdFunctions.vh"

	//
	// Bus Rate Timer
	//
	// The SPI Bus Rate is slower than the system clock so the State Machine
	//   will need to be paced to output bit changes at the bus rate.
	// The Tick Rate will be twice the Bus Rate so the State Machine will transition
	//   the clock on each cycle of the Bus Clock and read/write data every other cycle.
	//
	reg  bus_rate_timer_reset;

	// Compute Bus Timer Parameters
	localparam integer TIMER_TICKS = 2.0 * CLK_RATE_HZ / BUS_RATE_HZ;
	localparam TIMER_WIDTH = bit_index(TIMER_TICKS);
	localparam [TIMER_WIDTH:0] TIMER_LOADVAL = {1'b1, {TIMER_WIDTH{1'b0}}} - TIMER_TICKS[TIMER_WIDTH:0];

	reg [TIMER_WIDTH:0] timer_count_reg;
	wire timer_tick = timer_count_reg[TIMER_WIDTH]; // Use the counter rollover bit as the timer tick
 
	initial
	begin
		timer_count_reg <= TIMER_LOADVAL;
	end

	always @(posedge CLK, posedge bus_rate_timer_reset)
	begin
		if (bus_rate_timer_reset)
			timer_count_reg <= TIMER_LOADVAL;
		else
			timer_count_reg <= timer_count_reg + 1'b1;
	end

	//
	// Rollover Counter Counter Load Values
	//
	localparam [3:0] BIT_COUNT_LOADVAL = 4'h0; // 8 Bits
	localparam [3:0] BYTE_COUNT_1_LOADVAL = 4'h7; // 1 Byte
	localparam [3:0] BYTE_COUNT_2_LOADVAL = 4'h6; // 2 Bytes
	localparam [3:0] BYTE_COUNT_3_LOADVAL = 4'h5; // 3 Bytes
	localparam [3:0] BYTE_COUNT_4_LOADVAL = 4'h4; // 4 Bytes
	localparam [3:0] BYTE_COUNT_5_LOADVAL = 4'h3; // 5 Bytes
	localparam [3:0] BYTE_COUNT_6_LOADVAL = 4'h2; // 6 Bytes
	localparam [3:0] BYTE_COUNT_7_LOADVAL = 4'h1; // 7 Bytes
	localparam [3:0] BYTE_COUNT_8_LOADVAL = 4'h0; // 8 Bytes

	//
	// Register Declarations
	//
	reg  [(DATA_LENGTH_32-1+8):0] shift_reg_tx;  // Transmit Shift Register
		// !!NOTICE: Transmit data width can be variable from 1 byte instruction cicle + 2 Bytes(16) to 8 Bytes(64)
		// 			 depending on different register accessed.
		//				 So the bit width should be 8+16 or 8+32 or 8+48 or 8+64
		// reg [7:0] shift_reg_tx; 
	reg 	[(DATA_LENGTH_16-1+8):0] shift_reg_tx_16; 
	//reg   [7:0] shift_reg_rx;  // Receiver Shift Register

	reg   [3:0] bit_count;     // Bit Counter
	reg   [3:0] byte_count;    // Byte Counter

	reg         op_rw;
	reg   [4:0] op_addr;

	wire bit_count_done = bit_count[3];
	wire byte_count_done = byte_count[3];
	reg  bgin = 1'b0; //1'b0
	
	//
	// Initialize signals which do not need to be Reset
	//
	initial
	begin
		shift_reg_tx <= {(DATA_LENGTH_32-1+8){1'b0}};
		shift_reg_tx_16 <= {(DATA_LENGTH_16-1+8){1'b0}}; 
		//shift_reg_rx <= 8'h00;
		bit_count <= BIT_COUNT_LOADVAL;
		byte_count <= BYTE_COUNT_2_LOADVAL; //!?
		SPI_IO_UPDATE <= 1'b0;
	end
		
	//
	// SPI Transceiver State Machine
	//

	reg [9:0] State;
	localparam [9:0]
		S0 = 10'b0000000001,
		S1 = 10'b0000000010,
		S2 = 10'b0000000100,
		S3 = 10'b0000001000,
		S4 = 10'b0000010000,
		S5 = 10'b0000100000,
		S6 = 10'b0001000000,
		S7 = 10'b0010000000,
		S8 = 10'b0100000000,
		S9 = 10'b1000000000;

	always @(posedge CLK, posedge RESET)
	begin

		if (RESET)
		begin
			State	<= S0;
			SPI_CS_N <= 1'b1;	//SPI Bus Chip Select (Active-Low)
			SPI_SCLK <= 1'b0;	//SPI Bus Serial Clock (Stall high)
			SPI_SDO <= 1'b0;	//SPI Bus Serial Data Out 
			SPI_IO_UPDATE <= 1'b0; // SPI Bus IO_UPDATE 
			DONE <= 1'b0;	//Operation Done
			//RD_DATA <= 8'h00;	//Read Data
			bus_rate_timer_reset <= 1'b1;	//Bus Rate Timer Reset
			op_addr <= 5'h00;	//Operation Address
			op_rw <= 1'b0;	//Operation Read/Write
			bgin <= 1'b0;
		end
		else
		begin

			case (State)

				S0 :
				begin
					SPI_SCLK <= 1'b0;
					// Assert the Bus Rate Timer Reset
					bus_rate_timer_reset <= 1'b1;
					// Clear Done signal
					DONE <= 1'b0;
					// Clear IO_UPDATE
					SPI_IO_UPDATE <= 1'b0;
					// Wait for the Start signal
					bgin <= START;
					if (bgin)
						State <= S1;
				end

				S1 :
				begin
					// Set the Operation Parameters
					// !! WRITE ONLY
					if (!OPER) //WRITE
						begin
							op_rw <= 1'b0;
							op_addr <= ADDR;
								// Input might be 2-8 Bytes
								// Actually select between 2 bytes and 4 bytes based on ADDR (only first four regs)
							//byte_count <= BYTE_COUNT_5_LOADVAL; 
							case (ADDR)
								5'h01: byte_count <= BYTE_COUNT_3_LOADVAL;
								default: byte_count <= BYTE_COUNT_5_LOADVAL;
							endcase
						end
					/*
					// !! NOTICE: Only WRITE/READ are needed. 
					if (!OPER) //WRITE
						begin
							op_rw <= 1'b0;
							op_addr <= ADDR;
							byte_count <= BYTE_COUNT_4_LOADVAL;
						end
					else // READ
						begin
							op_rw <= 1'b1;
							op_addr <= ADDR;
							byte_count <= BYTE_COUNT_4_LOADVAL;
						end
					*/
					// Load the Bit Counter for 8-bits
					bit_count <= BIT_COUNT_LOADVAL;
					State <= S2;
				end

				S2 :
				begin
					// Load the Transmit Data into the TX Shift Register
					case (ADDR)
						//5'h01: shift_reg_tx <= { op_rw, 2'b0, op_addr, WR_DATA[15:0], 16'b0 }; // Filling in zeros after 2 bytes 
						5'h01: shift_reg_tx_16 <= { op_rw, 2'b0, op_addr, WR_DATA_16 };
						default: shift_reg_tx <= { op_rw, 2'b0, op_addr, WR_DATA }; 
					endcase
					//shift_reg_tx <= { op_rw, 2'b0, op_addr, WR_DATA }; //{ op_inst, op_addr, WR_DATA }; 
						// !!NOTICE: For AD9913, op_rw is the first single bit of the first byte, [7]; 
						//			  op_addr is the last five bits of the first byte, [4:0];
						//			  WR_DATA is the bytes after the first byte, can be 2-bytes to 8-bytes wide.
						// 		shift_reg_tx is [23:0], then:
						//			shift_reg_tx <= {op_rw, 1'b0, 1'b0, op_addr, WR_DATA}
						// !!NOTICE: WR_DATA might need to be 2-8 Bytes input, depending on op_addr.
					// Assert SPI Chip Select (Active-Low)
					SPI_CS_N <= 1'b0;
					// Start the Bus Rate Timer
					bus_rate_timer_reset <= 1'b0;
					// Wait for next Timer Tick
					if (timer_tick)
						State <= S3;
				end

				S3 : 
				// OUTPUT / WRITE (SDO)
				begin
					// Output SCLK Falling-Edge 
					SPI_SCLK <= 1'b0;
					// Output the Transmit Data (MSB first)
					case (ADDR)
						//5'h01: shift_reg_tx <= { op_rw, 2'b0, op_addr, WR_DATA[15:0], 16'b0 }; // Filling in zeros after 2 bytes 
						5'h01: SPI_SDO <= shift_reg_tx_16[(DATA_LENGTH_16-1+8)]; 
						default: SPI_SDO <= shift_reg_tx[(DATA_LENGTH_32-1+8)]; 
					endcase
					//SPI_SDO <= shift_reg_tx[(DATA_LENGTH_32-1+8)]; 
					// Reset the Bus Rate Timer
					bus_rate_timer_reset <= 1'b1;
					// Increment the Byte Counter on the last bit
					// Check Bit Counter Done
					if (bit_count_done)
						begin
							byte_count <= byte_count + 1'b1; //!!??
							State <= S7;
						end
					else
						State <= S4;
				end

				S4 :
				begin
					// Start the Bus Rate Timer
					bus_rate_timer_reset <= 1'b0;
					// Wait for next Timer Tick
					if (timer_tick)
						begin
							if (byte_count_done)
								begin
									// High SCLK output
									//SPI_SCLK <= 1'b1;
									State <= S8;
								end
							else
								State <= S5;
						end
				end

				S5 :
				// INPUT / READ (SDI)
				begin
					// SCLK Rising-Edge
					SPI_SCLK <= 1'b1;
					// Shift in the Received Data
						// !!! NOTICE: Might not be necessary if only WRITE to DDS. 
						// 				[No READ from DDS, so no input to SDI]
					//shift_reg_rx <= { shift_reg_rx[6:0], SPI_SDI };
					// !!! Shift in the next Transmit Data
					case (ADDR)
						5'h01: shift_reg_tx_16 <= { shift_reg_tx_16[(DATA_LENGTH_16-1+8-1):0], 1'b0 };
						default: shift_reg_tx <= { shift_reg_tx[(DATA_LENGTH_32-1+8-1):0], 1'b0 };
					endcase
					//shift_reg_tx <= { shift_reg_tx[(DATA_LENGTH_32-1+8-1):0], 1'b0 };
					// Increment the Bit Count
					bit_count <= bit_count + 1'b1;
					// Reset the bus rate timer
					bus_rate_timer_reset <= 1'b1;
					State <= S6;
				end

				S6 :
				begin
					// Start the Bus Rate Timer
					bus_rate_timer_reset <= 1'b0;
					// Wait for next timer tick
					if (timer_tick)
						State <= S3;
				end

				S7 :
				begin
					// Load the Bit Conuter for 8-bits
					bit_count	<= BIT_COUNT_LOADVAL;
					// Start the Bus Rate Timer
					bus_rate_timer_reset <= 1'b0;
					// If Reading, output the Read Data
					// !! NOTICE: Not necessary as only SPI_SDO is only needed output.
					// READ can be a simple shift register that accept input directly from SDI
					// !! NOTICE: output data might have variable byte length. 
					/*
					if (op_rw)
						RD_DATA <= shift_reg_rx;
					*/
					State <= S4;
				end

				S8 :
				begin
					// Deassert SPI Chip Select (Active-Low)
					SPI_CS_N <= 1'b1;
					// Reset the Bus Rate Timer
					bus_rate_timer_reset <= 1'b1;
					State <= S9;
				end

				S9 :
				begin
					// Start the Bus Rate Timer
					bus_rate_timer_reset <= 1'b0;
					// Assert Done on the Timer Tick
					if (timer_tick)
					begin 
						DONE <= 1'b1;
						SPI_IO_UPDATE <= 1'b1;
					end
						bgin <= 1'b0;
					// Wait for next Timer Tick
					if (timer_tick & !(START))
						State <= S0;
				end
				
			endcase

		end

	end

endmodule
