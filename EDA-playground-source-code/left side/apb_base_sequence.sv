///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// File Name: apb_base_sequence.sv
// Description: APB Base Sequence file 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class apb_base_sequence extends uvm_sequence#(apb_seq_item, apb_seq_item);// Specifies the request/response transaction type
  
  `uvm_object_utils(apb_base_sequence)//
  // sequence fields/
  bit [`ADDR_WIDTH-1:0] addr; // for holding addr
  bit [`DATA_WIDTH-1:0] data; // for holding data
  // The addr and data here act as temporary variables used within the sequence

  // seq_item instance
  apb_seq_item item;
    
  // constructor function
  function new(string name="apb_base_sequence");
      super.new(name);
  endfunction: new
    
  
  virtual task body();
    
  endtask: body
  
endclass: apb_base_sequence