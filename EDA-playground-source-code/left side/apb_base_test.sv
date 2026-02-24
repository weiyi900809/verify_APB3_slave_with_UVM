///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// File Name: apb_base_test.sv
// Description: apb base test
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class apb_base_test extends uvm_test;
    `uvm_component_utils(apb_base_test)
    
    // instance of env
    apb_environment     apb_env;
    
  
    // constructor function
    function new(string name="apb_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction: new

    // build_phase
    virtual function void build_phase(uvm_phase phase);
    
        // build env 
        apb_env = apb_environment::type_id::create("apb_env", this);
        
        super.build_phase(phase);
        
        // configure env_cfg
        /*
        apb_env.apb_mstr_agnt.is_active = UVM_ACTIVE;*/
      	
      
      uvm_config_db#(uvm_active_passive_enum)::set(this, "apb_env.apb_mstr_agnt.*", "is_active", UVM_ACTIVE);

        
      
        

      
    endfunction: build_phase
    
    // connect_phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase
    
    // run_phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // task: rd_nd_compare_mem
    // input parameters:
    //                      addr: Memory address to read
    //                      exp_data: expected data for comparing
    // Description:         Read data from the specified address and send the expected data to scoreboard.
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    task rd_nd_compare_mem(input [`ADDR_WIDTH-1:0] addr, input [`DATA_WIDTH-1:0] exp_data);
        // declare the sequence
        apb_rd_sequence  rd_seq;
        
        // create the sequence
        rd_seq = apb_rd_sequence::type_id::create("rd_seq", this);
        
        // configure sequence
        rd_seq.addr = addr;
        
        // start the sequence
        rd_seq.start(apb_env.apb_mstr_agnt.apb_mstr_seqr);
        
        // send the expected data to scoreboard for comparing
        apb_env.apb_scb.construct_nd_push_exp_pkt(addr, exp_data);
    endtask
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // task: rd_data_4m_mem
    // input parameters:
    //                      addr: Memory address to read
    //                      rand_addr: flag to enable random address selection
    // Description:         Read data from the specified address
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    task rd_data_4m_mem(input [`ADDR_WIDTH-1:0] addr, input bit rand_addr);
        // declare the sequence
        apb_rd_sequence  rd_seq;
        
        // create the sequence
        rd_seq = apb_rd_sequence::type_id::create("rd_seq", this);
        
        // configure sequence
        rd_seq.addr = addr;
        rd_seq.rand_addr = rand_addr;
        
        // start the sequence
        rd_seq.start(apb_env.apb_mstr_agnt.apb_mstr_seqr);
    endtask: rd_data_4m_mem
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // task: wr_rand_data_2_mem
    // input parameters:
    //                      addr: Memory address to write
    //                      data: Data to write
    //                      rand_addr: flag to enable random address selection
    //                      rand_data: flag to enable random data write
    // Description:         Read data from the specified address
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    task wr_data_2_mem(input [`ADDR_WIDTH-1:0] addr, input [`DATA_WIDTH-1:0] data, input bit rand_addr, input bit rand_data);
        // declare the sequence
        apb_wr_sequence  wr_seq;
        
        // create the sequence
        wr_seq = apb_wr_sequence::type_id::create("wr_seq", this);
        
        // configure sequence
        wr_seq.addr = addr;
        wr_seq.data = data;
        wr_seq.rand_addr = rand_addr;
        wr_seq.rand_data = rand_data;
        
        // start the sequence
        wr_seq.start(apb_env.apb_mstr_agnt.apb_mstr_seqr);
    endtask: wr_data_2_mem
    
    
    
 /*   
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // task: generate_mem_rd_err
    // input parameters:
    //                      addr: Memory address to read
    //                      rand_addr: flag to enable random address selection
    // Description:         Initiate read transfer with memory out of bound error
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    task generate_mem_rd_err(input [`ADDR_WIDTH-1:0] addr, input bit rand_addr);
        // declare the sequence
        apb_err_rd_sequence  rd_seq;
        
        // create the sequence
        rd_seq = apb_err_rd_sequence::type_id::create("rd_seq", this);
        
        // configure sequence
        rd_seq.addr = addr;
        rd_seq.rand_addr = rand_addr;
        
        // start the sequence
        rd_seq.start(apb_env.apb_mstr_agnt.apb_mstr_seqr);
    endtask: generate_mem_rd_err
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // task: generate_mem_wr_err
    // input parameters:
    //                      addr: Memory address to write
    //                      data: Data to write
    //                      rand_addr: flag to enable random address selection
    //                      rand_data: flag to enable random data write
    // Description:         Initiate write transfer with memory out of bound error
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    task generate_mem_wr_err(input [`ADDR_WIDTH-1:0] addr, input [`DATA_WIDTH-1:0] data, input bit rand_addr, input bit rand_data);
        // declare the sequence
        apb_err_wr_sequence  wr_seq;
        
        // create the sequence
        wr_seq = apb_err_wr_sequence::type_id::create("wr_seq", this);
        
        // configure sequence
        wr_seq.addr = addr;
        wr_seq.data = data;
        wr_seq.rand_addr = rand_addr;
        wr_seq.rand_data = rand_data;
        
        // start the sequence
        wr_seq.start(apb_env.apb_mstr_agnt.apb_mstr_seqr);
    endtask: generate_mem_wr_err*/
endclass : apb_base_test