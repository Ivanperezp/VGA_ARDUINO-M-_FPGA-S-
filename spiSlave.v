module spiSlave (
    input wire clk,           // FPGA system clock
    input wire rst_n,         // Active low reset
    input wire sclk,          // SPI clock from Arduino
    input wire cs_n,          // Chip select (active low)
    input wire mosi,          // Master out, slave in
    output reg miso,          // Master in, slave out
    output reg [7:0] rx_data, // Received data
    output reg rx_valid       // Received data valid flag
);

// This code applies to SPI mode 0-0

// Multi-stage synchronizers for SPI inputs
reg [2:0] sclk_sync;
reg [1:0] cs_n_sync;
reg [1:0] mosi_sync;

// Edge detection
wire sclk_rising;
wire sclk_falling;

// SPI state tracking
reg [2:0] bit_count;
reg [7:0] rx_shift;

// Synchronize inputs to FPGA clock domain
always @(posedge clk or negedge rst_n) begin	
	if (!rst_n) begin
		sclk_sync <= 3'b000;
		cs_n_sync <= 2'b11;
		mosi_sync <= 2'b00;
	end else begin
		sclk_sync <= {sclk_sync[1:0], sclk};
		cs_n_sync <= {cs_n_sync[0], cs_n};
		mosi_sync <= {mosi_sync[0], mosi};
	end
end
	
// Edge detection logic
assign sclk_rising = (sclk_sync[2:1] == 2'b01);
assign sclk_falling = (sclk_sync[2:1] == 2'b10);
		
		
// Main SPI logic
always @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      bit_count <= 3'b000;
      rx_shift <= 8'h00;
      rx_data <= 8'h00;
      rx_valid <= 1'b0;
   end else begin
      // Default state
      rx_valid <= 1'b0;
            
		   // Only process when slave is selected
         if (!cs_n_sync[1]) begin
		      // Sample on rising/falling edge based on SPI mode
			   // For Mode 0 (CPOL=0, CPHA=0), sample on rising edge
            if (sclk_rising) begin
               rx_shift <= {rx_shift[6:0], mosi_sync[1]};
                     
               // Check if we've received a complete byte
               if (bit_count == 3'b111) begin
                  rx_data <= {rx_shift[6:0], mosi_sync[1]};
                  rx_valid <= 1'b1;
						bit_count <= 3'b000;
               end else 				
                  bit_count <= bit_count + 1;
            end
         end
	end
end

endmodule