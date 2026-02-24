///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// File Name: apb_monitor.sv
// Description: APB Monitor
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    // virtual interface instance
    virtual apb_interface apb_intf_mntr;
    
  	bit exp_err; //put exp_err at monitor 
  
  
    // analysis port instance
  	uvm_analysis_port#(apb_seq_item)    mntr2scb;         // analysis port to be connected with scoreboard
        
    
    // constructor function
    function new(string name="apb_monitor", uvm_component parent);
        super.new(name, parent);
        
        // create analysis port
        mntr2scb = new("mntr2scb", this);

      
    endfunction: new 
    
    // build_phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual apb_interface)::get(this, "", "apb_interface", apb_intf_mntr)) begin
            `uvm_fatal("NO APB_INTF ERROR", "Monitor cannot obtain virtual interface! please check config_db setting")
        end
      	
    endfunction: build_phase
    
    // connect_phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase
    
    // run_phase
    virtual task run_phase(uvm_phase phase);
        apb_seq_item item;
        super.run_phase(phase);
        
        forever begin
            if(apb_intf_mntr.PSEL) begin
                while(apb_intf_mntr.PENABLE) begin 
                    // create seq_item           
                    item = apb_seq_item::type_id::create("item");
                    
                    wait(apb_intf_mntr.PREADY ==1);
                    if(apb_intf_mntr.PWRITE == 1) begin
                        if(apb_intf_mntr.PSLVERR) begin
                            if(exp_err) begin
                                `uvm_info("DUT_ERROR_TEST", $sformatf("DUT has successfully detected ADDRESS OUT OF BOUND Error and Error response is triggered"), UVM_LOW)
                                @(apb_intf_mntr.cb);
                            end
                            else begin
                                `uvm_error("DUT_OP_ERROR", $sformatf("DUT has report an error during write operation using PSLVERR signal."))
                                @(apb_intf_mntr.cb);
                            end
                        end
                        else begin
                            `uvm_info("MNTR", $sformatf("WRITE type Seq_item send from monitor \n"), UVM_LOW)
                            item.op_type = WRITE;
                            item.ADDR = apb_intf_mntr.PADDR;
                            item.DATA = apb_intf_mntr.PWDATA;
                            @(apb_intf_mntr.cb);
                            
                          
                        end    
                    end
                    else if(apb_intf_mntr.PWRITE == 0) begin
                        if(apb_intf_mntr.PSLVERR) begin
                            if(exp_err) begin
                                `uvm_info("DUT_ERROR_TEST", $sformatf("DUT has successfully detected ADDRESS OUT OF BOUND Error and Error response is triggered"), UVM_LOW)
                                @(apb_intf_mntr.cb);
                            end
                            else begin
                                `uvm_error("DUT_OP_ERROR", $sformatf("DUT has report an error during read operation using PSLVERR signal."))
                                @(apb_intf_mntr.cb);
                            end
                        end
                        else begin
                            `uvm_info("MNTR", $sformatf("READ type Seq_item send from monitor\n"), UVM_LOW)
                            item.op_type = READ;
                            item.ADDR = apb_intf_mntr.PADDR;
                            item.DATA = apb_intf_mntr.PRDATA;
                          	// send the item to scoreboard for checking
                            mntr2scb.write(item);// ###origin is down
                            @(apb_intf_mntr.cb);
                            
                        
                            
                        end
                    end
                end
            end
            @(apb_intf_mntr.cb);
        end
 
    endtask: run_phase
endclass: apb_monitor