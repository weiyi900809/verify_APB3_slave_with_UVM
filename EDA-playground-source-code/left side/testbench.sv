// File Name: tb_top.sv
// Description: tb_top module


`timescale 1ns/1ps


`include "apb_pkg.sv"
`include "apb_interface.sv"

import apb_pkg::*;

module tb_top();

    
    // clock declaration
    bit clk;

    // interface declaration
    apb_interface   apb_intf(clk);
    
  
    
    // 100MHz clock generation block
    initial begin
        forever begin
            #((0.5 / `APB_CLK_FREQ_MHZ) * 1us) clk = ~clk;
        end
    end
      
    // instantiation of DUT
    apb_slave  DUT (       
                        // IO ports
                        .pclk(clk),                          // 100MHz clock
      					.presetn(apb_intf.PRESETn),             // Active low Reset
                        .psel(apb_intf.PSEL),                   // Select Signal
                        .penable(apb_intf.PENABLE),             // Enable Signal
                        .pwrite(apb_intf.PWRITE),               // Write Strobe
                        .paddr(apb_intf.PADDR),                 // Addr
                        .pwdata(apb_intf.PWDATA),               // Write data
      
                        .prdata(apb_intf.PRDATA),               // Read data
                        .pready(apb_intf.PREADY),               // Slave Ready
                        .pslverr(apb_intf.PSLVERR)              // Slave Error Response
                    );
                    
    // set interface in uvm config db 
    initial begin
       
        
      	uvm_config_db#(virtual apb_interface)::set(null, "*", "apb_interface", apb_intf);
      	
        // start the test
      	run_test("apb_rand_reg_write_read_test");
    end
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
  	end
endmodule: tb_top