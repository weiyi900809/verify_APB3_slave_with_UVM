///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// File Name: apb_mstr_agent.sv
// Description: APB Master agent
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class apb_mstr_agent extends uvm_agent;
    `uvm_component_utils(apb_mstr_agent)
    
    // apb_mstr_driver instance
    apb_master_driver       apb_mstr_drvr;
    
    // apb_monitor instance
    apb_monitor             apb_mntr;
    
    // apb_mstr_sequencer instance
    apb_mstr_sequencer      apb_mstr_seqr;
  
    // virtual interface instance
    //virtual apb_interface apb_intf_agent;
    
    // put " is_active" in agent
  	uvm_active_passive_enum is_active = UVM_ACTIVE;
  	
  	// put " exp_err" in agent 
  	bit exp_err; 
  
    // constructor function
    function new(string name="apb_mstr_agent", uvm_component parent);
        super.new(name, parent);
    endfunction: new
    
    // build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        
        /*if(!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_interface", apb_intf_agent)) begin
          `uvm_fatal("NO APB_INTF ERROR", "agent cannot obtain virtual interface! please check config_db setting")
        end*/
      
      	// build monitor
        apb_mntr = apb_monitor::type_id::create("apb_mntr", this);
      
        // build driver and sequencer if agent is active
        if(is_active == UVM_ACTIVE) begin
            // build driver
            apb_mstr_drvr = apb_master_driver::type_id::create("apb_mstr_drvr", this);
            
            // build sequencer
            apb_mstr_seqr = apb_mstr_sequencer::type_id::create("apb_mstr_seqr", this);
        end
        
        
    endfunction: build_phase
    
    // connect_phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // connect driver and sequencer ports and interface handles if agent is active
        if(is_active == UVM_ACTIVE) begin
            
          
            // connect interface handle inside driver with interface 
            //apb_mstr_drvr.apb_intf_drv = apb_intf_agent;
            
            // connect sequence item ports of driver and sequencer
            apb_mstr_drvr.seq_item_port.connect(apb_mstr_seqr.seq_item_export);
        end
        
        
        // connect monitor interface with interface
        //apb_mntr.apb_intf_mntr = apb_intf_agent;
        
        
      
      
    endfunction: connect_phase
endclass: apb_mstr_agent