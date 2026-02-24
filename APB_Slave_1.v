`define DATAWIDTH 8
`define ADDRWIDTH 8

module apb_slave (
    input wire pclk,              // Clock signal
    input wire presetn,           // Active-low reset
    input wire psel,              // Select signal from master
    input wire penable,           // Enable signal from master
    input wire pwrite,            // Write signal: 1 for write, 0 for read
    input wire [`ADDRWIDTH-1:0] paddr,       // Address from master
    input wire [`DATAWIDTH-1:0] pwdata,      // Write data from master
    output reg [`DATAWIDTH-1:0] prdata,      // Read data to master
    output reg pready,            // Ready signal to master
    output reg pslverr            // Error signal to master
);

    // Internal memory: 256 bytes
    //reg [7:0] memory [255:0];
	reg [`DATAWIDTH-1:0] memory [0:2**`ADDRWIDTH -1]; //2**`ADDRWIDTH -1 = 2^(ADDRWIDTH)-1 = 2^8 -1 = 256-1 
	
    // Address register
    reg [`ADDRWIDTH -1:0] addr_reg;

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
			addr_reg <= {`ADDRWIDTH{1'b0}};
			
        end 
		else begin
            // Pre-setting default values for each cycle 
			/*
			這是一個防呆機制。它確保了 pready 和 pslverr 預設是不發生的（0），只有當後面的邏輯判斷「確定完成傳輸」或「確定發生錯誤」時，才會將 = 1。
			*/
            pready <= 1'b0;
            pslverr <= 1'b0;

            if (psel) begin
                // Handle Read Operations
                if (!pwrite && penable) begin
					//if (paddr < 8'd256) begin
                    if (paddr < (2**`ADDRWIDTH) ) begin // (2**`ADDRWIDTH)
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
					if (paddr < (2**`ADDRWIDTH)) begin // (2**`ADDRWIDTH)
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
