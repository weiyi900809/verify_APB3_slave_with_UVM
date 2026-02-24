package apb_pkg;

  	import uvm_pkg::*;           
  	`include "uvm_macros.svh"    

  	`include "tb_defines.sv"      // ADDR_WIDTH, DATA_WIDTH, op_type_e 等
	


  	`include "apb_seq_item.sv"

    `include "apb_base_sequence.sv"
    `include "apb_rd_sequence.sv"
    `include "apb_wr_sequence.sv"
    


  	`include "apb_mstr_sequencer.sv"
	`include "apb_mstr_driver.sv"
  	`include "apb_monitor.sv"
  	`include "apb_scoreboard.sv"
  	`include "apb_mstr_agent.sv"
  	`include "apb_env.sv"

  	// test
  	`include "apb_base_test.sv"
  	`include "apb_rand_reg_write_read_test.sv"
	`include "apb_reg_por_read_test.sv"
  
endpackage : apb_pkg
