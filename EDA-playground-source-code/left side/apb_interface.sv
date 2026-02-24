interface apb_interface (input logic PCLK);

    // 1. Signal Definitions (Mapped to RTL ports)
    // Note: defined as logic, direction controlled by modport or clocking block
  	logic                   PRESETn;   // Reset ( TB control)
    logic                   PSEL;      // Master -> Slave
    logic                   PENABLE;   // Master -> Slave
    logic                   PWRITE;    // Master -> Slave
    logic [`ADDR_WIDTH-1:0]  PADDR;     // Master -> Slave
    logic [`DATA_WIDTH-1:0]  PWDATA;    // Master -> Slave
    logic [`DATA_WIDTH-1:0]  PRDATA;    // Slave -> Master
    logic                   PREADY;    // Slave -> Master
    logic                   PSLVERR;   // Slave -> Master

    // 2. Clocking Block (Master/Driver perspective)
    // Used to resolve Race Conditions and simplify Driver timing
    clocking cb @(posedge PCLK);
        default input #1ns output #1ns; // Setup/Hold time simulation
        
        // Outputs for Driver (Driving to DUT)
        output PSEL;
        output PENABLE;
        output PWRITE;
        output PADDR;
        output PWDATA;
        
        // Inputs for Driver (Reading from DUT)
        input  PRDATA;
        input  PREADY;
        input  PSLVERR;
    endclocking : cb

    // 3. Modport Declaration
    // Defines signal access and direction
  
    // Master Modport: Used by Driver
    modport master (
        clocking cb,       // Use clocking block for drive/sample
        output   PRESETn   // Reset is usually controlled by Test directly or via interface task
    );

    

    // 4. Tasks (Encapsulated common operations)
    
    // Reset Task: Allows Driver to call vif.reset_intf()
    task reset_intf();
        $display("[INTF] Applying Reset...");
        PRESETn <= 0;
        PSEL    <= 0;
        PENABLE <= 0;
        PWRITE  <= 0;
        PADDR   <= 0;
        PWDATA  <= 0;
        
      	repeat(2) @(posedge PCLK); // Hold Reset for 10 cycles
        PRESETn <= 1;
        @(posedge PCLK);
        $display("[INTF] Reset Released.");
    endtask

    // Wait for Reset release 
    task wait_for_reset();
        wait(PRESETn === 1);
        @(posedge PCLK);
    endtask

    // 5. Assertions (SVA) - Protocol Checkers
    
    // Check 1: PENABLE must be asserted one cycle after PSEL (APB Protocol)
    // Checks if Master behavior complies with standard
    property p_psel_valid;
        @(posedge PCLK) disable iff(!PRESETn) 
        ($rose(PSEL) && !PENABLE) |=> $rose(PENABLE);
    endproperty
    
    // Check 2: PSEL must remain High until PREADY is high during transfer
    property p_psel_hold;
        @(posedge PCLK) disable iff(!PRESETn)
        (PSEL && PENABLE && !PREADY) |=> PSEL;
    endproperty

    // Check 3: PWDATA should not be unknown (X) during write
    property p_write_data_valid;
        @(posedge PCLK) disable iff(!PRESETn)
        (PSEL && PENABLE && PWRITE) |-> !$isunknown(PWDATA);
    endproperty

    // Activate assertions
    assert property(p_psel_valid)       else $error("APB Violation: PENABLE not asserted after PSEL");
    assert property(p_psel_hold)        else $error("APB Violation: PSEL dropped before PREADY");
    assert property(p_write_data_valid) else $error("APB Violation: Writing X data");

endinterface : apb_interface