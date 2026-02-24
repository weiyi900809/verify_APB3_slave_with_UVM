`include "tb_defines.sv"

module apb_slave (
    input wire pclk,              // Clock signal
    input wire presetn,           // Active-low reset
    input wire psel,              // Select signal from master
    input wire penable,           // Enable signal from master
    input wire pwrite,            // Write signal: 1 for write, 0 for read
    input wire [`ADDR_WIDTH-1:0] paddr,       // Address from master
    input wire [`DATA_WIDTH-1:0] pwdata,      // Write data from master
  
    output reg [`DATA_WIDTH-1:0] prdata,      // Read data to master
    output reg pready,            // Ready signal to master
    output reg pslverr            // Error signal to master
);

    // Internal memory: 256 bytes
    //reg [7:0] memory [255:0];
	reg [`DATA_WIDTH-1:0] memory [0:2**`ADDR_WIDTH -1]; //2**`ADDR_WIDTH -1 = 2^(ADDR_WIDTH)-1 = 2^8 -1 = 256-1 
	
    // Address register
    reg [`ADDR_WIDTH -1:0] addr_reg;

	// FSM state
    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ACCESS = 2'b10;

    reg [1:0] current_state;
	
	
    // Reset and initialization logic
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            pready <= 1'b0; 
            pslverr <= 1'b0;
			//addr_reg <= 8'b0;
			addr_reg <= {`ADDR_WIDTH{1'b0}};
			
        end 
		else begin
            // Pre-setting default values for each cycle 
			
            pready <= 1'b0;
            pslverr <= 1'b0;

            if (psel) begin
                // Handle Read Operations
                if (!pwrite && penable) begin
					//if (paddr < 8'd256) begin
                    if (paddr < (2**`ADDR_WIDTH) ) begin // (2**`ADDR_WIDTH)
                        addr_reg <= paddr;
                        prdata <= memory[paddr];    // Read data from memory
                        pready <= 1'b1;             // Indicate successful transfer
                    end else begin
                        pslverr <= 1'b1;            // Address out of range
                        pready <= 1'b1;
                    end
                end

                // Handle Write Operations
                if (pwrite && penable) begin
                    //if (paddr < 8'd256) begin  
					if (paddr < (2**`ADDR_WIDTH)) begin // (2**`ADDR_WIDTH)
                        memory[paddr] <= pwdata;    // Write data to memory
                        pready <= 1'b1;             // Indicate successful transfer
                    end else begin
                        pslverr <= 1'b1;            // Address out of range
                        pready <= 1'b1;
                    end
                end
            end
        end
    end

endmodule
