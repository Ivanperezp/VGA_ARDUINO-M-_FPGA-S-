module vram#(
    parameter ADDR_WIDTH = 11,   // 1KB memory
    parameter DATA_WIDTH = 8    // Byte-wide data
)
(
input wire clk,
input wire rx_valid,
input wire [DATA_WIDTH - 1: 0] data_in,
output reg ready_flag, // Indicates vram is ready to be read from
input wire read_en, // Vram data reading enable
output reg [DATA_WIDTH - 1: 0] data_out,
input wire rst_n,
input [ADDR_WIDTH - 1 : 0] read_addr
); 
	
	parameter x_size = 40;
	parameter y_size = 30;
	
	parameter addr_size = x_size * y_size;
	
	reg rx_valid_prev;
	wire rx_rising;
	
	reg [DATA_WIDTH - 1 : 0] buffer [0 : addr_size - 1];
	reg [DATA_WIDTH - 1 : 0] ram [0 : addr_size - 1];
	
	reg [ADDR_WIDTH : 0] write_ptr;
	
	reg full_flag; // Indicates buffer is full 
	
	always @(posedge clk) begin
		if (!rst_n)
			rx_valid_prev <= 1'b0;
		else
			rx_valid_prev <= rx_valid;
	end
	
	assign rx_rising = rx_valid == 1'b1 && rx_valid_prev == 1'b0;
	
	// Vram management logic
	always @(posedge clk) begin
		if (!rst_n) begin
			write_ptr <= 0;
			full_flag <= 0;
			data_out <= 0;
			ready_flag <= 0;
		end else begin
			// Buffer logic
			if (rx_rising && !full_flag) begin
				buffer[write_ptr] <= data_in;
		
				if (write_ptr == addr_size - 1) begin
					full_flag <= 1'b1;
					write_ptr <= 0; // Will be reused as pointer for vram data writing
				end else
					write_ptr <= write_ptr + 1;
			end
			
			// Vram writing logic
			if (full_flag && !ready_flag) begin
				ram[write_ptr] <= buffer[write_ptr];
				
				if (write_ptr == addr_size - 1)
					ready_flag <= 1'b1;
				else
					write_ptr <= write_ptr + 1;
			end
			
			// Vram reading logic
			if (ready_flag && read_en) begin
				data_out <= ram[read_addr];
			end
		end
	end
	
endmodule
