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
        
        // Initial synchronization
        wait(apb_intf_mntr.PRESETn === 1); // Wait for Reset release
        @(apb_intf_mntr.cb);
        
        forever begin
            // -----------------------------------------------------------------
            // Phase 1: Look for Setup Phase (Wait until PENABLE is LOW)
            // -----------------------------------------------------------------
            // This step is critical to prevent double sampling!
            // If PENABLE is still 1 (residue from the previous transaction), 
            // the loop will hold here and will NOT sample.
            do begin
                @(apb_intf_mntr.cb);
            end while ( !(apb_intf_mntr.PSEL && !apb_intf_mntr.PENABLE) );

            // Setup Phase detected. Latch address and control signals.
            // Create the item here to store the address information first.
            item = apb_seq_item::type_id::create("item");
            item.ADDR = apb_intf_mntr.PADDR;
            item.op_type = (apb_intf_mntr.PWRITE) ? WRITE : READ;

            // -----------------------------------------------------------------
            // Phase 2: Wait for Access Phase completion (PENABLE=1, PREADY=1)
            // -----------------------------------------------------------------
            do begin
                @(apb_intf_mntr.cb);
            end while ( !(apb_intf_mntr.PENABLE && apb_intf_mntr.PREADY) );

            // -----------------------------------------------------------------
            // Phase 3: Sample Data and Write to Analysis Port
            // -----------------------------------------------------------------
            if (item.op_type == WRITE) begin
              	if(apb_intf_mntr.PSLVERR) begin
                  if(exp_err) begin
                  `uvm_info("DUT_ERROR_TEST", $sformatf("DUT has successfully detected ADDRESS OUT OF BOUND Error and Error response is triggered"), UVM_LOW)
                  
                  end
                  else begin
                    `uvm_error("DUT_OP_ERROR", $sformatf("DUT has report an error during write operation using PSLVERR signal."))
                  
                  end
                end
              	else begin
                  item.DATA = apb_intf_mntr.PWDATA;
              
                  // Optional: Write transaction can also be sent to scoreboard if needed
                  // mntr2scb.write(item); 
                end  
                
            end 
            else begin
              	if(apb_intf_mntr.PSLVERR) begin
                  if(exp_err) begin
                  `uvm_info("DUT_ERROR_TEST", $sformatf("DUT has successfully detected ADDRESS OUT OF BOUND Error and Error response is triggered"), UVM_LOW)
                  
                  end
                  else begin
                  `uvm_error("DUT_OP_ERROR", $sformatf("DUT has report an error during read operation using PSLVERR signal."))
                  
                  end
                end
              	else begin
                  	item.DATA = apb_intf_mntr.PRDATA;
                	mntr2scb.write(item); // Send to Scoreboard
                end  
                
            end
            
            // Processing done. Loop back to the start.
            // This forces the logic to enter "Phase 1" again and wait for PENABLE to become 0.
        end
    endtask: run_phase

endclass: apb_monitor
