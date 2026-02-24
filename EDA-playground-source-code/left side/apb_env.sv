///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// File Name: apb_env.sv
// Description: APB Environment 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class apb_environment extends uvm_env;
    `uvm_component_utils(apb_environment)
    
    
    // instance of scoreboard
    apb_scoreboard  apb_scb;
    // instance of agent
    apb_mstr_agent  apb_mstr_agnt;
  	
  
    
    // constructor function
    function new(string name="apb_environment", uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    // build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        
        
        // build agent
        apb_mstr_agnt = apb_mstr_agent::type_id::create("apb_mstr_agnt", this);
        
        
        
        apb_scb = apb_scoreboard::type_id::create("apb_scb", this);
        
        
        
    endfunction: build_phase
    
    // connect_phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        
        
        // connect monitor and scoreboard
        apb_mstr_agnt.apb_mntr.mntr2scb.connect(apb_scb.ap_mntr2scb);
        // connect driver and scoreboard
        apb_mstr_agnt.apb_mstr_drvr.drv2scb.connect(apb_scb.ap_drv2scb);
           
    endfunction: connect_phase
    
    // run_phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase
endclass: apb_environment
