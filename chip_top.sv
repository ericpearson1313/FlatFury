`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2025 03:28:59 PM
// Design Name: 
// Module Name: new_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Wrap demo top in a new system verilog top

module chip_top(
    // DDR3
    output wire [14:0]  DDR3_addr,
    output wire [2:0]   DDR3_ba,
    output wire         DDR3_cas_n,
    output wire [0:0]   DDR3_ck_n,
    output wire [0:0]   DDR3_ck_p,
    output wire [0:0]   DDR3_cke,
    output wire [1:0]   DDR3_dm,
    inout  wire [15:0]  DDR3_dq,
    inout  wire [1:0]   DDR3_dqs_n,
    inout  wire [1:0]   DDR3_dqs_p,
    output wire [0:0]   DDR3_odt,
    output wire         DDR3_ras_n,
    output wire         DDR3_reset_n,
    output wire         DDR3_we_n,
    
    // LEDs
    output wire         LED_A1,
    output wire         LED_A2,
    output wire         LED_A3,
    output wire         LED_A4,
    output wire         LED_M2,
    
    // SPI Flash
    inout  wire         SPI_0_io0_io,
    inout  wire         SPI_0_io1_io,
    inout  wire         SPI_0_io2_io,
    inout  wire         SPI_0_io3_io,
    input  wire         SPI_0_ss_i,
    output wire         real_spi_ss,   
     
    // PCI port
    input  wire         pci_reset,
    input  wire [0:0]   pcie_clkin_clk_n,
    input  wire [0:0]   pcie_clkin_clk_p,
    output wire [0:0]   pcie_clkreq_l,
    input  wire [0:0]   pcie_mgt_rxn,
    input  wire [0:0]   pcie_mgt_rxp,
    output wire [0:0]   pcie_mgt_txn,
    output wire [0:0]   pcie_mgt_txp,
   
    // OSC clock input
    input  wire         sys_clk_clk_n,
    input  wire         sys_clk_clk_p,
    
    // HDMI output Port 4x LVDS Pairs
    output wire         hdmi_ck_p,
    output wire         hdmi_d0_p,
    output wire         hdmi_d1_p,
    output wire         hdmi_d2_p,
    output wire         hdmi_ck_n,
    output wire         hdmi_d0_n,
    output wire         hdmi_d1_n,
    output wire         hdmi_d2_n
    );                          

    // Tie off unused memory port
    assign DDR3_addr    = 0;
    assign DDR3_ba      = 0;
    assign DDR3_cas_n   = 1;
    assign DDR3_ck_n    = 1;
    assign DDR3_ck_p    = 0;
    assign DDR3_cke     = 0;
    assign DDR3_dm      = 0;
    assign DDR3_dq      = 16'hzzzz;   
    assign DDR3_dqs_n   = 2'hz;
    assign DDR3_dqs_p   = 2'hz;  
    assign DDR3_odt     = 0;
    assign DDR3_ras_n   = 1;
    assign DDR3_reset_n = 0;
    assign DDR3_we_n    = 1;

    // Tie off SPI
    assign SPI_0_io0_io = 1'hz;
    assign SPI_0_io1_io = 1'hz;
    assign SPI_0_io2_io = 1'hz;
    assign SPI_0_io3_io = 1'hz;
    assign real_spi_ss  = 1'b0;
    
    // Tie off PCI
    assign pcie_clkreq_l = 0;
    
    // Tie off LEDs
    //assign LED_A1 = 1'b0;
    //assign LED_A2 = 1'b1;
    //assign LED_A3 = 1'b0;
    //assign LED_A4 = 1'b0;
    assign LED_M2 = 1'b0;

    // 200 Mhz? OSC input (was for ddr3 controller)
    logic sys_clk; // only oscillator input on the Fury
    IBUFDS  ( .O( sys_clk ), .I ( sys_clk_clk_p ), .IB( sys_clk_clk_n ) );

    // system clock reset
    logic [15:0] reset_count; // assumed init to 0 by fpga
    logic        sys_reset;
    always_ff @(posedge sys_clk) begin
        if( !(&reset_count) ) reset_count <= reset_count + 1;
        sys_reset <= !(&reset_count);
    end
    
    // System pps, timign source with 1 second toggle rate
    logic pps;
    logic [31:0] seconds;
    logic [31:0] pps_counter;
    always @(posedge sys_clk) begin 
        if( sys_reset ) begin
            pps <= 0;
            pps_counter <= 32'h0;
            seconds <= 32'h0;
        end else begin
            pps_counter <= ( pps_counter == (32'd200_000_000 - 1 )) ? 0 : pps_counter + 1;
            pps <= ( pps_counter == (32'd200_000_000 - 1 ) ) ? !pps : pps;
            seconds <= ( pps_counter == (32'd200_000_000 - 1 ) ) ? seconds + 1 : seconds;
        end
    end
    
    
    // Blink LEDs
    logic [26:0] blink_count;
    always_ff @(posedge sys_clk)  blink_count <= ( sys_reset ) ? 0 :blink_count + 1;
    assign LED_A1 = blink_count[26];
    assign LED_A2 = blink_count[25];
    assign LED_A3 = blink_count[24];
    assign LED_A4 = user_link_up;    
    
    ///////////////////////////
    //  AXI-PCIe Interface
    /////////////////////////// 
       
    // Output Interface Signals
    logic user_link_up;    
    logic axi_clk;  
    logic axi_reset;  
    logic axi_ctl_clk;
    logic mmcm_lock;          
      
    // M-AXI Bus Definiations
    logic        m_axi_awvalid ; logic        m_axi_arvalid ; logic        m_axi_wvalid ; logic        m_axi_rvalid ; logic        m_axi_bvalid ;    
    logic        m_axi_awready ; logic        m_axi_arready ; logic        m_axi_wready ; logic        m_axi_rready ; logic        m_axi_bready ;    
    logic [31:0] m_axi_awaddr  ; logic [31:0] m_axi_araddr  ; logic [63:0] m_axi_wdata  ; logic [63:0] m_axi_rdata  ; logic [1:0]  m_axi_bresp  ;
    logic [7:0]  m_axi_awlen   ; logic [7:0]  m_axi_arlen   ; logic        m_axi_wlast  ; logic        m_axi_rlast  ; 
    logic [2:0]  m_axi_awsize  ; logic [2:0]  m_axi_arsize  ; logic [7:0]  m_axi_wstrb  ; logic [1:0]  m_axi_rresp  ; 
    logic [1:0]  m_axi_awburst ; logic [1:0]  m_axi_arburst ; 
    logic [2:0]  m_axi_awprot  ; logic [2:0]  m_axi_arprot  ; 
    logic        m_axi_awlock  ; logic        m_axi_arlock  ;     
    logic [3:0]  m_axi_awcache ; logic [3:0]  m_axi_arcache ; 
    
    // S-AXI Bus definitions
    logic        s_axi_awvalid ; logic        s_axi_arvalid ; logic        s_axi_wvalid ; logic        s_axi_rvalid ; logic        s_axi_bvalid ;
    logic        s_axi_awready ; logic        s_axi_arready ; logic        s_axi_wready ; logic        s_axi_rready ; logic        s_axi_bready ;
    logic [3:0]  s_axi_awid    ; logic [3:0]  s_axi_arid    ;                           ; logic [3:0]  s_axi_rid    ; logic [3:0]  s_axi_bid    ;
    logic [31:0] s_axi_awaddr  ; logic [31:0] s_axi_araddr  ; logic [63:0] s_axi_wdata  ; logic [63:0] s_axi_rdata  ; logic [1:0]  s_axi_bresp  ;
    logic [7:0]  s_axi_awlen   ; logic [7:0]  s_axi_arlen   ; logic        s_axi_wlast  ; logic        s_axi_rlast  ; 
    logic [2:0]  s_axi_awsize  ; logic [2:0]  s_axi_arsize  ; logic [7:0]  s_axi_wstrb  ; logic [1:0]  s_axi_rresp  ; 
    logic [1:0]  s_axi_awburst ; logic [1:0]  s_axi_arburst ;
    logic [3:0]  s_axi_awregion; logic [3:0]  s_axi_arregion;
    
    // S-AXI CTRL control bus defiitions
    logic        s_axi_ctl_awvalid ; logic        s_axi_ctl_arvalid ; logic        s_axi_ctl_wvalid ; logic        s_axi_ctl_rvalid ; logic        s_axi_ctl_bvalid ;
    logic        s_axi_ctl_awready ; logic        s_axi_ctl_arready ; logic        s_axi_ctl_wready ; logic        s_axi_ctl_rready ; logic        s_axi_ctl_bready ;
    logic [31:0] s_axi_ctl_awaddr  ; logic [31:0] s_axi_ctl_araddr  ; logic [63:0] s_axi_ctl_wdata  ; logic [63:0] s_axi_ctl_rdata  ; logic [1:0]  s_axi_ctl_bresp  ;
                                                                      logic [ 3:0] s_axi_ctl_wstrb  ; logic [1:0]  s_axi_ctl_rresp  ; 
    
    // PCI Clock Input buffer
    logic REFCLK;      
    IBUFDS_GTE2 IBUFDS_GTE2_inst (.I( pcie_clkin_clk_p ), .IB( pcie_clkin_clk_n ), .O( REFCLK ), .ODIV2( ), .CEB( 1'b0 ) );
     
    // Create axi_reset, must wait 16x axi_clocks after  mmcm_lock 
    // Make sure it does not rely upon a stable mmcm_lock beign stable. Thye can be touchy
    logic [15:0] rst_shift;
    always_ff@( posedge axi_clk ) begin
        if( !pci_reset ) begin
            rst_shift <= 16'b0000;
        end else if( rst_shift == 16'h0000 && mmcm_lock ) begin
            rst_shift <= 16'h0001;
        end else if( rst_shift == 16'hFFFF ) begin
            rst_shift <= 16'hFFFF;
        end else if ( rst_shift != 0 ) begin
            rst_shift <= { rst_shift[14:0], 1'b1 };
        end
    end
    assign axi_reset = !rst_shift[15];
      
    // Instantiate the generated Xilinx AXI-PCIe core
    axi_pcie_ip i_pcie (
        .REFCLK          ( REFCLK      ),
        .axi_aresetn     ( !axi_reset  ),
        .user_link_up    ( user_link_up ),
        .axi_aclk_out    ( axi_clk ),
        .axi_ctl_aclk_out( axi_ctl_clk ),
        .mmcm_lock       ( mmcm_lock ),
    
         // PCIE Links
        .pci_exp_txp ( pcie_mgt_txp ), 
        .pci_exp_txn ( pcie_mgt_txn ), 
        .pci_exp_rxp ( pcie_mgt_rxp ), 
        .pci_exp_rxn ( pcie_mgt_rxn ), 
        
        // MSI/.Interrupt interface
        .interrupt_out    (   ),
        .INTX_MSI_Request ( 0 ),
        .INTX_MSI_Grant   (   ),
        .MSI_enable       (   ),
        .MSI_Vector_Num   ( 0 ),
        .MSI_Vector_Width (   ),
        
        // S_AXI port, 64 R/W access to PCIe DMA direcdt access
        // Tied off AW, W, B busses for nowbit 
        .s_axi_awvalid ( 0 ), .s_axi_arvalid ( s_axi_arvalid  ), .s_axi_wvalid( 0 ), .s_axi_rvalid( s_axi_rvalid  ), .s_axi_bvalid(   ),
        .s_axi_awready (   ), .s_axi_arready ( s_axi_arready  ), .s_axi_wready(   ), .s_axi_rready( s_axi_rready  ), .s_axi_bready( 0 ),
        .s_axi_awid    ( 0 ), .s_axi_arid    ( s_axi_arid     ),                     .s_axi_rid   ( s_axi_rid     ), .s_axi_bid   (   ),
        .s_axi_awaddr  ( 0 ), .s_axi_araddr  ( s_axi_araddr   ), .s_axi_wdata ( 0 ), .s_axi_rdata ( s_axi_rdata   ), .s_axi_bresp (   ),
        .s_axi_awlen   ( 0 ), .s_axi_arlen   ( s_axi_arlen    ), .s_axi_wlast ( 0 ), .s_axi_rlast ( s_axi_rlast   ),
        .s_axi_awsize  ( 0 ), .s_axi_arsize  ( s_axi_arsize   ), .s_axi_wstrb ( 0 ), .s_axi_rresp ( s_axi_rresp   ),
        .s_axi_awburst ( 0 ), .s_axi_arburst ( s_axi_arburst  ),
        .s_axi_awregion( 0 ), .s_axi_arregion( s_axi_arregion ),
     
        // M_AXI port, 64 bti R/W access to on chip resources
        .m_axi_awvalid( m_axi_awvalid ), .m_axi_arvalid( m_axi_arvalid ), .m_axi_wvalid ( m_axi_wvalid  ), .m_axi_rvalid ( m_axi_rvalid  ), .m_axi_bvalid ( m_axi_bvalid  ), 
        .m_axi_awready( m_axi_awready ), .m_axi_arready( m_axi_arready ), .m_axi_wready ( m_axi_wready  ), .m_axi_rready ( m_axi_rready  ), .m_axi_bready ( m_axi_bready  ),
        .m_axi_awaddr ( m_axi_awaddr  ), .m_axi_araddr ( m_axi_araddr  ), .m_axi_wdata  ( m_axi_wdata   ), .m_axi_rdata  ( m_axi_rdata   ), .m_axi_bresp  ( m_axi_bresp   ),
        .m_axi_awlen  ( m_axi_awlen   ), .m_axi_arlen  ( m_axi_arlen   ), .m_axi_wlast  ( m_axi_wlast   ), .m_axi_rlast  ( m_axi_rlast   ),
        .m_axi_awsize ( m_axi_awsize  ), .m_axi_arsize ( m_axi_arsize  ), .m_axi_wstrb  ( m_axi_wstrb   ), .m_axi_rresp  ( m_axi_rresp   ),
        .m_axi_awburst( m_axi_awburst ), .m_axi_arburst( m_axi_arburst ),
        .m_axi_awprot ( m_axi_awprot  ), .m_axi_arprot ( m_axi_arprot  ),
        .m_axi_awlock ( m_axi_awlock  ), .m_axi_arlock ( m_axi_arlock  ),
        .m_axi_awcache( m_axi_awcache ), .m_axi_arcache( m_axi_arcache ),
     
         // S_AXI_CTL, 32 bit port for PCIe core access
         // Tie off 
        .s_axi_ctl_awvalid ( s_axi_ctl_awvalid ), .s_axi_ctl_arvalid ( s_axi_ctl_arvalid ), .s_axi_ctl_wvalid( s_axi_ctl_wvalid ), .s_axi_ctl_rvalid( s_axi_ctl_rvalid ), .s_axi_ctl_bvalid( s_axi_ctl_bvalid ),
        .s_axi_ctl_awready ( s_axi_ctl_awready ), .s_axi_ctl_arready ( s_axi_ctl_arready ), .s_axi_ctl_wready( s_axi_ctl_wready ), .s_axi_ctl_rready( s_axi_ctl_rready ), .s_axi_ctl_bready( s_axi_ctl_bready ),
        .s_axi_ctl_awaddr  ( s_axi_ctl_awaddr  ), .s_axi_ctl_araddr  ( s_axi_ctl_araddr  ), .s_axi_ctl_wdata ( s_axi_ctl_wdata  ), .s_axi_ctl_rdata ( s_axi_ctl_rdata  ), .s_axi_ctl_bresp ( s_axi_ctl_bresp  ),
                                                                                            .s_axi_ctl_wstrb ( s_axi_ctl_wstrb  ), .s_axi_ctl_rresp ( s_axi_ctl_rresp  )
    ); 
 
    ////////////////////////////////////
    // AXI-S CTL Interface 
    ////////////////////////////////////
    // uses to set the AXI2PCIE mapping
    // the tool does not seem to support 64bi tpcie addresses, 
    // AXI BAR0 is 2G from 0x0000_0000 to 0x7FFF_FFFF
    // AXI BAR1 is 2G from 0x8000_0000 to 0xFFFF_FFFF
    // so we will set them thru this port
    // 0x208 31-0 AXIBAR2PCIEBAR_0U = 32'h0000_0010;
    // 0x20C 31-0 AXIBAR2PCIEBAR_0L = 32'h0000_0000;
    // 0x210 31-0 AXIBAR2PCIEBAR_1U = 32'h0000_0010;
    // 0x214 31-0 AXIBAR2PCIEBAR_1L = 32'h8000_0000;
    // Tie off for now and look into setting these registers via PCIE ECAM accesses
    assign s_axi_ctl_arvalid    =  1'b0;
    assign s_axi_ctl_araddr     = 32'h0;
    assign s_axi_ctl_wstrb      =  4'b1111;
    assign s_axi_ctl_rready     =  1'b1; 
    assign s_axi_ctl_bready     =  1'b1;
    
    // Addresses, data pairs for the 4 init writes on the axi-lite control port
    logic [0:3][0:1][31:0] init_writes = { 32'h0000_1208, 32'h0000_0010, 32'h0000_120C, 32'h0000_000, 32'h0000_1210, 32'h0000_0010, 32'h0000_1214, 32'h8000_0000 };
    
    // 4 Write cycles of: 
    // init_count[0] = 0 then set addr, data bus and set awvalid and wvalid 
    // init_count[0] = 1 then when awready or wready seen, wait  both drop go onto next write, 
    
    logic [2:0] init_count;
    always_ff @(posedge axi_clk) begin
        if( axi_reset ) begin
            init_count <= 0;
            s_axi_ctl_awvalid <= 0;
            s_axi_ctl_wvalid <= 0;
        end else begin
            init_count <= ( init_count == 8 ) ? 8 : ( !init_count[0] || (!s_axi_ctl_awvalid && !s_axi_ctl_wvalid )) ? init_count+1 : init_count;
            s_axi_ctl_awaddr <= init_writes[init_count[2:1]][0];
            s_axi_ctl_wdata  <= init_writes[init_count[2:1]][1];           
            s_axi_ctl_awvalid <= ( s_axi_ctl_awvalid & s_axi_ctl_awready ) ? 1'b0 : (!init_count[0] && init_count != 8) ? 1'b1 : s_axi_ctl_awvalid;
            s_axi_ctl_wvalid  <= ( s_axi_ctl_wvalid  & s_axi_ctl_wready  ) ? 1'b0 : (!init_count[0] && init_count != 8) ? 1'b1 : s_axi_ctl_wvalid;
        end
    end
       
    ////////////////////////////////////
    // AXI-M Interface 
    ////////////////////////////////////
       
    // Tie off master interface data
    assign m_axi_rdata[63:0] = 64'h0000_1234_5678_0000;
    assign m_axi_rlast       = 1'b1;
    assign m_axi_rresp[1:0]  = 2'b00; // OK
    assign m_axi_bresp[1:0]  = 2'b00; // OK
    
   // AR transaction and R response
   always_ff @(posedge axi_clk) begin
        m_axi_rvalid <= ( m_axi_rready && m_axi_rvalid ) ? 1'b0 :
                        ( m_axi_arvalid && m_axi_arready ) ? 1'b1 : m_axi_rvalid;
   end
   assign m_axi_arready = !m_axi_rvalid;

    // AW + W transacdtion adn B response
   always_ff @(posedge axi_clk) begin
        m_axi_bvalid <= ( m_axi_bready && m_axi_bvalid ) ? 1'b0 :
                        ( m_axi_awvalid && m_axi_awready && m_axi_wvalid && m_axi_wready ) ? 1'b1 : m_axi_bvalid;
   end
   assign m_axi_awready = !m_axi_bvalid & m_axi_awvalid & m_axi_wvalid;
   assign m_axi_wready  = !m_axi_bvalid & m_axi_awvalid & m_axi_wvalid;
    
	// AXI-M Monitor, Log
	// queue last 8 tranascitons of each of AW, AR, R
	logic [7:0][39:0] aw_hex_reg, ar_hex_reg;
	logic [7:0][12:0] aw_bin_reg, ar_bin_reg;
	logic [7:0][63:0]  w_hex_reg;
	logic [7:0][ 8:0]  w_bin_reg;
	always_ff @(posedge axi_clk) begin
		aw_hex_reg <= ( m_axi_awvalid && m_axi_awready ) ? { aw_hex_reg[6:0], { m_axi_awaddr, m_axi_awlen }} : aw_hex_reg;
		aw_bin_reg <= ( m_axi_awvalid && m_axi_awready ) ? { aw_bin_reg[6:0], { m_axi_awsize, m_axi_awburst, m_axi_awprot, m_axi_awlock, m_axi_awcache }} : aw_bin_reg;
		ar_hex_reg <= ( m_axi_arvalid && m_axi_arready ) ? { ar_hex_reg[6:0], { m_axi_araddr, m_axi_arlen }} : ar_hex_reg;
		ar_bin_reg <= ( m_axi_arvalid && m_axi_arready ) ? { ar_bin_reg[6:0], { m_axi_arsize, m_axi_arburst, m_axi_arprot, m_axi_arlock, m_axi_arcache }} : ar_bin_reg;
		w_hex_reg  <= ( m_axi_wvalid  && m_axi_wready  ) ? { w_hex_reg[6:0] , { m_axi_wdata }} : w_hex_reg;
		w_bin_reg  <= ( m_axi_wvalid  && m_axi_wready  ) ? { w_bin_reg[6:0] , { m_axi_wstrb, m_axi_wlast }} : w_bin_reg;
	end
		    
		    
	///////////////////////////
	// AXI-S Pcie Master DMA
	///////////////////////////
	
	// Read video and display in our 256x256 window
    
      
    // AR transactions
    	
    // Fixed values
	assign s_axi_arid     = 4'h0;    
	assign s_axi_arlen    = 8'hFF; // maximum axi 256 cycle burst of 8 bytes gives a 2kbyte burst
	assign s_axi_arsize   = 3'b011; // 64 bits, 8 bytes
	assign s_axi_arburst  = 2'b01;  // INCR
	assign s_axi_arregion = 4'h0;
	
	
	// Capture RAT address writes on the M-AXI bus, and toggle enable
	logic ar_enable;
	logic [31:0] rat_addr;
    always_ff @(posedge axi_clk) begin
        if( axi_reset ) begin
            ar_enable <= 0;
            rat_addr <= 0;
        end else begin
            if( ( m_axi_awvalid && m_axi_awready && 
                  m_axi_wvalid  && m_axi_wready  && 
                  m_axi_awaddr == 32'h0000_CCCC ) ) begin
                rat_addr <= m_axi_wdata[63-:32]; // msb word
                ar_enable <= 1;
            end
        end
    end
	
	// State machine for AXI-S DMA reads
    localparam S_IDLE       = 0;
    localparam S_ADDR_RAT   = 2;
    localparam S_LOAD_RAT   = 3;
    localparam S_ADDR_ROW   = 4;
    localparam S_LOAD_ROW   = 5;
    localparam S_WAIT_ROW   = 6;

    logic [3:0] state;
    logic [7:0] row_cnt, col_cnt;
    logic [3:0] vsync_c2c, win_c2c;
    always_ff @(posedge axi_clk) begin
        if( axi_reset ) begin
            state <= S_IDLE;
            vsync_c2c <= 0;
            win_c2c <= 0;
            row_cnt <= 0;
            col_cnt <= 0;
        end else begin
            vsync_c2c[3:0] <= {!vsync_c2c[2] & vsync_c2c[1], vsync_c2c[1:0], vsync }; // hdmmi vsync rise edge det after c2c, to start rat read.
            win_c2c[3:0]   <= {  win_c2c[2] &  !win_c2c[1],   win_c2c[1:0], win256}; // hdmi window falling edge after c2c, earliest moment to read next row
            case( state ) 
                S_IDLE     : begin state <= ( ar_enable & vsync_c2c[3]                    ) ? S_ADDR_RAT : S_IDLE    ; end
                S_ADDR_RAT : begin state <= ( s_axi_arvalid && s_axi_arready              ) ? S_LOAD_RAT : S_ADDR_RAT; end
                S_LOAD_RAT : begin state <= ( s_axi_rvalid  && s_axi_rready && s_axi_rlast ) ? S_ADDR_ROW : S_LOAD_RAT; end
                S_ADDR_ROW : begin state <= ( s_axi_arvalid && s_axi_arready              ) ? S_LOAD_ROW : S_ADDR_ROW; end
                S_LOAD_ROW : begin state <= ( s_axi_rvalid  && s_axi_rready && s_axi_rlast ) ? S_WAIT_ROW : S_LOAD_ROW; end
                S_WAIT_ROW : begin state <= ( win_c2c[3] && row_cnt == 0 ) ? S_IDLE : ( win_c2c[3] ) ? S_ADDR_ROW : S_WAIT_ROW; end
            endcase
	        row_cnt <= ( state == S_IDLE ) ? 0 : ( s_axi_arvalid && s_axi_arready && state == S_ADDR_ROW ) ? row_cnt+1 : row_cnt; // row address incremented as soon as used
	        col_cnt <= ( state == S_IDLE ) ? 0 : ( s_axi_rvalid  && s_axi_rready && s_axi_rlast ) ? 0 : ( s_axi_rvalid  && s_axi_rready ) ? col_cnt + 1 : col_cnt;
	    end
	end
	
    // Row address table
    logic [31:0] rat [0:255]; // Row address table memory
    logic [31:0] mapped;
    always_ff @(posedge axi_clk) begin
        if( s_axi_rvalid  && s_axi_rready && state == S_LOAD_RAT ) // write rat
            rat[col_cnt] <= { s_axi_rdata[31:11], 11'h000 }; // always 2K aligned
        mapped <= rat[row_cnt]; // rat read address 
    end
    
    // RGB Row buffer
    // write on AXI clock (and will read below in hdmi section
    logic [23:0] row_mem [0:255];
    logic [23:0] rgb_img;
    logic [ 7:0] vid_cnt;
    always_ff @(posedge axi_clk) begin
        if( s_axi_rvalid  && s_axi_rready && state == S_LOAD_ROW )
            row_mem[col_cnt] <= s_axi_rdata[63-:24];
    end        
    always_ff @(posedge hdmi_clk) begin // read on video clock
        vid_cnt <= ( win256 ) ? vid_cnt + 1 : 0;
        rgb_img <= row_mem[vid_cnt];
    end
        
    // AR transaction 
    assign s_axi_araddr = ( state == S_ADDR_RAT ) ? rat_addr : mapped;
    assign s_axi_arvalid = ( state ==  S_ADDR_RAT || state == S_ADDR_ROW ) ? 1'b1 : 1'b0; 
    assign s_axi_rready = ( state ==  S_LOAD_RAT || state == S_LOAD_ROW ) ? 1'b1 : 1'b0; 
    
     // PPS to second_tick
    logic second_tick;
    logic [2:0] c2c_pps;
    always_ff @( posedge axi_clk ) begin
        c2c_pps[2:0] <= { c2c_pps[1:0], pps };
        second_tick <= c2c_pps[2] ^ c2c_pps[1];
    end  

    // Perf counters
    logic [47:0] ar_bytes, r_bytes;
    logic [31:0] r_acc_bytes, ar_acc_bytes;
    logic [31:0] r_sec_bytes, ar_sec_bytes;    
    always @(posedge axi_clk ) begin
        ar_bytes     <= ar_bytes + ( ( s_axi_arvalid && s_axi_arready ) ? 'd2048 : 0 ); // our max burst len with 64 bit bus.
         r_bytes     <=  r_bytes + ( ( s_axi_rvalid && s_axi_rready ) ? 'd8    : 0 );
        ar_acc_bytes <= ( second_tick ) ? ( ( s_axi_arvalid && s_axi_arready ) ? 'd2048 : 0 ) : ar_acc_bytes + ( ( s_axi_arvalid && s_axi_arready ) ? 'd2048 : 0 );
         r_acc_bytes <= ( second_tick ) ? ( ( s_axi_rvalid  && s_axi_rready  ) ? 'd8    : 0 ) :  r_acc_bytes + ( ( s_axi_rvalid  && s_axi_rready  ) ? 'd8    : 0 );
        ar_sec_bytes <= ( second_tick ) ? ar_acc_bytes : ar_sec_bytes;
         r_sec_bytes <= ( second_tick ) ?  r_acc_bytes :  r_sec_bytes;
    end 
    
    
    // AXI-S Monitor, Log
	// queue last 8 of  R

	logic [7:0][63:0]  sr_hex_reg;
	logic [7:0][ 6:0]  sr_bin_reg;
	always_ff @(posedge axi_clk) begin
		sr_hex_reg <= ( s_axi_rready && s_axi_rvalid ) ? { sr_hex_reg[6:0], { s_axi_rdata }} : sr_hex_reg;
		sr_bin_reg <= ( s_axi_rready && s_axi_rvalid ) ? { sr_bin_reg[6:0], { s_axi_rid, s_axi_rlast, s_axi_rresp }} : sr_bin_reg;
	end

    ///////////////////////////
    // DAY-3 Logic
    ///////////////////////////     
    
    // brinup Test generator
    // Every vsync, emit a 256 cycle nibble vector with last
    logic [0:255][3:0] test_init = { 400'h4732321333332463233337712234322122322247222252423773321362313613333336333732233372323328332333322777, {156{4'h0}} };
    logic [0:255][3:0] test_buf; // shift register
    logic [3:0] test_data;
    logic       test_valid;
    logic       test_last;
    logic [7:0] test_count;
    always_ff @(posedge axi_clk ) begin
        if( vsync_c2c[3] ) begin // rising vsync edge
            test_buf    <= test_init;
            test_count  <= 0;
            test_last   <= 0;
            test_valid  <= 1;
        end else if( test_valid ) begin
            test_buf[0:255] <= { test_buf[1:255], 4'h0 }; //shift data
            test_count   <= test_count + 1;
            test_valid  <= ( test_count == 255 ) ? 1'b0 : 1'b1;
            test_last   <= ( test_count == 254 ) ? 1'b1 : 1'b0;
        end else begin
            test_buf <= test_buf;
            test_valid <= 0;
            test_last <= 0;
            test_count <= 0;
        end    
    end // always        
    assign test_data = test_buf[0];
    
    // common Data input buffer
    logic [255:0][3:0] data_buf;
    logic [1:0][255:0][3:0] best;
    always_ff @(posedge axi_clk ) begin  
        if( vsync_c2c ) begin
            data_buf <= 0;
            best <= 0;
        end else if( test_valid ) begin
            data_buf <= { data_buf[254:0], test_data };
            best[1] <= { best[1][254:0], ( data_buf[0] > best[1][0] ) ? data_buf[0] : best[1][0] };
            best[0] <= { best[0][254:0], ( data_buf[0] > best[1][0] ) ? test_data   : 
                                         ( test_data   > best[0][0] ) ? test_data   : best[0][0] };
        end
    end // always
    
    // Display on HDMI screen
    logic [20:0] aoc_ov;
	string_overlay #(.LEN( 11  )) i_aoc0(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 22 ), .out( aoc_ov[0] ), .str( "Day 3 Part 1" ) );
	hex_overlay    #(.LEN( 100 )) i_aoc1(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 23 ), .out( aoc_ov[1] ), .in( data_buf[255-:100] ) ); 
	hex_overlay    #(.LEN( 100 )) i_aoc2(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 24 ), .out( aoc_ov[2] ), .in( best[0][255-:100] ) );    	    
	hex_overlay    #(.LEN( 100 )) i_aoc3(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 25 ), .out( aoc_ov[3] ), .in( best[1][255-:100] ) );    	    
	 
    ///////////////////////////
    // HDMI Video Output
    ///////////////////////////     
    
    // PLL to creaet HDMI Clock
    sys_pll i_sys_pll 
    (
        .clk_in1    ( sys_clk   ),
        .hdmi_clk   ( hdmi_clk  ), 
        .hdmi_clk5  ( hdmi_clk5 ),
        .reset      ( sys_reset ),
        .locked     (           )
    );
 
	logic [3:0] hdmi_reg;
	always @(posedge hdmi_clk) begin
		hdmi_reg[3:0] <= { hdmi_reg[2:0], sys_reset };
	end
	logic reset;
	assign reset = hdmi_reg[3];
	
	// XVGA 800x480x60hz sych generator	
	logic video_preamble;
	logic data_preamble;
	logic video_guard;
	logic data_guard;
	logic data_island;
	logic blank, hsync, vsync;
	vga_800x480_sync i_sync
	(
		.clk(   hdmi_clk   ),	
		.reset( reset ),
		.blank( blank ),
		.hsync( hsync ),
		.vsync( vsync ),
		// HDMI encoding controls
		.video_preamble( video_preamble ),
		.data_preamble ( data_preamble  ),
		.video_guard   ( video_guard    ),
		.data_guard    ( data_guard     ),
		.data_island   ( data_island    )
	);
	

	// Font Generator
	logic [7:0] char_x, char_y;
	logic [255:0] ascii_char;
	logic [15:0] hex_char;
	logic [1:0] bin_char;
	ascii_font57 i_font
	(
		.clk( hdmi_clk ),
		.reset( reset ),
		.blank( blank ),
		.hsync( hsync ),
		.vsync( vsync ),
		.char_x( char_x ), // 0 to 105 chars horizontally
		.char_y( char_y ), // o to 59 rows vertically
		.hex_char   ( hex_char ),
		.binary_char( bin_char ),
		.ascii_char ( ascii_char )	
	);

	// test pattern gen
	logic [7:0] test_red, test_green, test_blue;
	test_pattern i_testgen 
	(
		.clk( hdmi_clk  ),
		.reset( reset ),
		.blank( blank ),
		.hsync( hsync ),
		.vsync( vsync ),
		.red	( test_red   ),
		.green  ( test_green ),
		.blue	( test_blue  )
	);	
	

	// Text Overlay (from flash rom)
	// Important to put commit hash in flash, 
	// otherwise influences the build reproduction logic
	
	logic text_ovl;
	logic [3:0] text_color;
	text_overlay_rom i_text
	(
		.clk( hdmi_clk  ),
		.reset( reset ),
		.blank( blank ),
		.hsync( hsync ),
		.vsync( vsync ),
		// Overlay output bit for ORing
		.overlay( text_ovl ),
		.color( text_color )
	);

    // Monitor S-AXI RA prot, latched at vsync
    logic [31:0] v_addr;
    logic        v_read;
    // sample during vsync
    always_ff @( posedge hdmi_clk ) begin
        if( vsync ) begin
            v_addr <= s_axi_araddr;
            v_read <= ar_enable;
        end
    end
    
    // Overlay 256x256 window
    localparam WINX = 799-256;
    localparam WINY = 200-24;
    logic window_fg;
    logic window_bg;
    logic win256;
    logic [9:0] xloc, yloc;
    logic vsync_del;
    logic blank_del;
    always_ff @(posedge hdmi_clk ) begin
        vsync_del <= vsync;
        blank_del <= blank;
        xloc <= ( blank ) ? 0 : xloc + 1;
        yloc <= ( vsync & !vsync_del ) ? 0 : ( blank & !blank_del ) ? yloc + 1 : yloc;
        if( xloc >= WINX && xloc < WINX+256 && yloc >= WINY && yloc < WINY+256 ) begin // Inside the window
            if( v_read && xloc-WINX == v_addr[23:16] || v_read && yloc-WINY == v_addr[31:24] ) begin
                window_fg <= 1;
                window_bg <= 0;
            end else if( xloc == WINX || xloc == WINX+255 || yloc == WINY || yloc == WINY+255 ) begin
                window_fg <= 1;
                window_bg <= 0;
            end else begin      
                window_fg <= 0;
                window_bg <= 1;
            end
        end else begin
            window_fg <= 0;
            window_bg <= 0;
        end
    end
    assign win256 = window_fg | window_bg;   // used to select the buffer 
    
    // Ovelay dynamic text
    logic [15:0] txt_str;
	string_overlay #(.LEN( 7 )) i_txt0(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 1 ), .out( txt_str[0] ), .str( "Seconds" ) );
	hex_overlay    #(.LEN( 8 )) i_txt1(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 1 ), .out( txt_str[1] ), .in( seconds ) );    
	string_overlay #(.LEN( 6 )) i_txt2(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 3 ), .out( txt_str[2] ), .str( "ReadEn" ) );
	bin_overlay    #(.LEN( 3 )) i_txt3(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x( 116 ), .y( 3 ), .out( txt_str[3] ), .in( { ar_enable, s_axi_arvalid, s_axi_arready } ) );
    string_overlay #(.LEN( 6 )) i_txt4(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 5 ), .out( txt_str[4] ), .str( "ARaddr" ) );
    hex_overlay    #(.LEN( 8 )) i_txt5(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 5 ), .out( txt_str[5] ), .in( s_axi_araddr ) );
    
    string_overlay #(.LEN( 8 )) i_txt6(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 7 ), .out( txt_str[6] ), .str( "AR bytes" ) );
    hex_overlay    #(.LEN( 12)) i_txt7(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 7 ), .out( txt_str[7] ), .in( ar_bytes ) );
    string_overlay #(.LEN( 8 )) i_txt8(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 9 ), .out( txt_str[8] ), .str( " R bytes" ) );
    hex_overlay    #(.LEN( 12)) i_txt9(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 9 ), .out( txt_str[9] ), .in(  r_bytes ) );
    string_overlay #(.LEN( 8 )) i_txta(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 11), .out( txt_str[10]), .str( "ARbyte/s" ) );
    hex_overlay    #(.LEN( 8 )) i_txtb(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 11), .out( txt_str[11]), .in( ar_sec_bytes ) );
    string_overlay #(.LEN( 8 )) i_txtc(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 13), .out( txt_str[12]), .str( " Rbyte/s" ) );
    hex_overlay    #(.LEN( 8 )) i_txtd(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 13), .out( txt_str[13]), .in(  r_sec_bytes ) );
    string_overlay #(.LEN( 8 )) i_txte(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 107 ), .y( 15), .out( txt_str[14]), .str( "RATpaddr" ) );
    hex_overlay    #(.LEN( 8 )) i_txtf(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x( 116 ), .y( 15), .out( txt_str[15]), .in(  rat_addr ) );


    // AXI Log of M-AXIregister live Overlay Generators
	logic [7:0][9:0] aw_ovl, ar_ovl, w_ovl, r_ovl;
	//genvar gg;
	//generate
	//	for( gg = 0; gg < 10; gg++ ) begin : aw_text
	//		int row = gg + 22;
	//		int col = 0;
	//		// AW Log Text Overlay
	//		if( gg == 0 ) begin : aw_title
	//			string_overlay #(.LEN(41 )) i_id0(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x(col+7 ), .y(row), .out( aw_ovl[0][gg] ), .str( "AW Address  Len Size Brst Prot Lock Cache" ) );
	//		end else if ( gg >= 2 ) begin : aw_fields
	//			hex_overlay    #(.LEN( 8 )) i_id1(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+10), .y(row), .out( aw_ovl[1][gg] ), .in( aw_hex_reg[gg-2][39-:32] ) );
	//			hex_overlay    #(.LEN( 2 )) i_id2(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+19), .y(row), .out( aw_ovl[2][gg] ), .in( aw_hex_reg[gg-2][ 7-:8 ] ) );
	//			bin_overlay    #(.LEN( 3 )) i_id3(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+23), .y(row), .out( aw_ovl[3][gg] ), .in( aw_bin_reg[gg-2][12-:3 ] ) );
	//			bin_overlay    #(.LEN( 2 )) i_id4(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+28), .y(row), .out( aw_ovl[4][gg] ), .in( aw_bin_reg[gg-2][ 9-:2 ] ) );
	//			bin_overlay    #(.LEN( 3 )) i_id5(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+33), .y(row), .out( aw_ovl[5][gg] ), .in( aw_bin_reg[gg-2][ 7-:3 ] ) );
	//			bin_overlay    #(.LEN( 1 )) i_id6(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+38), .y(row), .out( aw_ovl[6][gg] ), .in( aw_bin_reg[gg-2][ 4-:1 ] ) );
	//			bin_overlay    #(.LEN( 4 )) i_id7(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+43), .y(row), .out( aw_ovl[7][gg] ), .in( aw_bin_reg[gg-2][ 3-:4 ] ) );
	//		end
	//	end
	//	// AR Log Text Overlay
	//	for( gg = 0; gg < 10; gg++ ) begin : ar_text
	//		int row = gg + 10;
	//		int col = 0;
	//		if( gg == 0 ) begin : ar_title
	//			string_overlay #(.LEN(41 )) i_id8(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x(col+7 ), .y(row), .out( ar_ovl[0][gg] ), .str( "AR Address  Len Size Brst Prot Lock Cache" ) );
	//		end else if ( gg >= 2 ) begin : ar_fields
	//			hex_overlay    #(.LEN( 8 )) i_id9(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+10), .y(row), .out( ar_ovl[1][gg] ), .in( ar_hex_reg[gg-2][39-:32] ) );
	//			hex_overlay    #(.LEN( 2 )) i_ida(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+19), .y(row), .out( ar_ovl[2][gg] ), .in( ar_hex_reg[gg-2][ 7-:8 ] ) );
	//			bin_overlay    #(.LEN( 3 )) i_idb(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+23), .y(row), .out( ar_ovl[3][gg] ), .in( ar_bin_reg[gg-2][12-:3 ] ) );
	//			bin_overlay    #(.LEN( 2 )) i_idc(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+28), .y(row), .out( ar_ovl[4][gg] ), .in( ar_bin_reg[gg-2][ 9-:2 ] ) );
	//			bin_overlay    #(.LEN( 3 )) i_idd(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+33), .y(row), .out( ar_ovl[5][gg] ), .in( ar_bin_reg[gg-2][ 7-:3 ] ) );
	//			bin_overlay    #(.LEN( 1 )) i_ide(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+38), .y(row), .out( ar_ovl[6][gg] ), .in( ar_bin_reg[gg-2][ 4-:1 ] ) );
	//			bin_overlay    #(.LEN( 4 )) i_idf(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+43), .y(row), .out( ar_ovl[7][gg] ), .in( ar_bin_reg[gg-2][ 3-:4 ] ) );
	//		end
	//	end
	//	// W Log Text Overlay
	//	for( gg = 0; gg < 10; gg++ ) begin : w_text
	//		int row = gg + 22;
	//		int col = 42;
	//		if( gg == 0 ) begin : ar_title
	//            string_overlay #(.LEN(34 )) i_idg(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x(col+7 ), .y(row), .out(  w_ovl[0][gg] ), .str( " W Write Data        Strobe   Last" ) );
	//		end else if ( gg >= 2 ) begin : ar_fields
	//			hex_overlay    #(.LEN(16 )) i_idh(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+10), .y(row), .out(  w_ovl[1][gg] ), .in( w_hex_reg[gg-2][63-:64] ) );
	//			bin_overlay    #(.LEN( 8 )) i_idi(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+28), .y(row), .out(  w_ovl[2][gg] ), .in( w_bin_reg[gg-2][ 8-:8 ] ) );
	//			bin_overlay    #(.LEN( 1 )) i_idj(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+37), .y(row), .out(  w_ovl[3][gg] ), .in( w_bin_reg[gg-2][ 0-:1 ] ) );
	//		end
	//	end
	//	// S R log overlay
	//	// W Log Text Overlay
	//	for( gg = 0; gg < 10; gg++ ) begin : sr_text
	//		int row = gg + 35;
	//		int col = 42;
	//		if( gg == 0 ) begin : r_title
	//            string_overlay #(.LEN(35 )) i_idk(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x(col+7 ), .y(row), .out(  r_ovl[0][gg] ), .str( "SR Read Data         Id   Last Resp" ) );
	//		end else if ( gg >= 2 ) begin : ar_fields
	//			hex_overlay    #(.LEN(16 )) i_idl(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+10), .y(row), .out(  r_ovl[1][gg] ), .in( sr_hex_reg[gg-2][63-:64] ) );
	//			bin_overlay    #(.LEN( 4 )) i_idm(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+28), .y(row), .out(  r_ovl[2][gg] ), .in( sr_bin_reg[gg-2][ 6-:4 ] ) );
	//			bin_overlay    #(.LEN( 1 )) i_idn(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+33), .y(row), .out(  r_ovl[3][gg] ), .in( sr_bin_reg[gg-2][ 2-:1 ] ) );
	//			bin_overlay    #(.LEN( 2 )) i_idp(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+38), .y(row), .out(  r_ovl[4][gg] ), .in( sr_bin_reg[gg-2][ 1-:2 ] ) );
	//		end
	//	end
	//	
	//endgenerate


	// Overlay Text - Dynamic
	logic [31:0] id_str;
	
	string_overlay #(.LEN(29 )) i_id0(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 20 ), .y( 1 ), .out( id_str[0]), .str( "HDMI WVGA output 800x480x60Hz" ) );
	string_overlay #(.LEN(14 )) i_id1(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 20 ), .y( 3 ), .out( id_str[1]), .str( "PCIe Link Up =" ) );
    bin_overlay    #(.LEN(1  )) i_id2(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x( 35 ), .y( 3 ), .out( id_str[2]), .in( user_link_up ) );
    

	

	// Mix overlays
	logic overlay;
	assign overlay = ( text_ovl && text_color == 0 ) | // normal text
						  (|id_str) | (|aw_ovl) | (|ar_ovl) | (|w_ovl) | (|r_ovl)| (|txt_str) ; // OR of Reduction ORs!
	
	// Overlay Color
	logic [7:0] overlay_red, overlay_green, overlay_blue;
	assign { overlay_red, overlay_green, overlay_blue } =
			( overlay   ) ? 24'hFFFFFF :
			( window_fg ) ? 24'h00c0c0 /* smpte_turquise_surf */ :
			( window_bg ) ? 24'h1d1d1d /* smpte_eerie_black   */ :
			( text_ovl && text_color == 4'h1 ) ? 24'hf00000 :
			( text_ovl && text_color == 4'h2 ) ? 24'hFFFFFF :
			( text_ovl && text_color == 4'h3 ) ? 24'hff0000 :			
			( text_ovl && text_color == 4'h4 ) ? 24'h00ff00 :
			( text_ovl && text_color == 4'h5 ) ? 24'h0000ff :
			( text_ovl && text_color == 4'h6 ) ? 24'hc0c0c0 :
			( text_ovl && text_color == 4'h7 ) ? 24'h0000c0 :
			( text_ovl && text_color == 4'h8 ) ? 24'h00c0c0 :
			( text_ovl && text_color == 4'h9 ) ? 24'h00c000 : 
			( text_ovl && text_color == 4'hA ) ? 24'hc0c000 : 
			( text_ovl                       ) ? 24'hf0f000 : 
															 24'h000000 ;

	// video encoder
	// Simultaneous HDMI and DVI
	logic [7:0] hdmi_data;
	logic [7:0] dvi_data;
	video_encoder i_encode2
	(
		.clk  ( hdmi_clk  ),
		.clk5 ( hdmi_clk5 ),
		.reset( reset ),  
		.blank( blank ),
		.hsync( hsync ),
		.vsync( vsync ),
		// HDMI encoding control
		.video_preamble( video_preamble ),
		.data_preamble ( data_preamble  ),
		.video_guard   ( video_guard    ),
		.data_guard    ( data_guard     ),
		.data_island   ( data_island    ),	
		// YUV mode input
		.yuv_mode		( 0 ), // use YUV2 mode, cheap USb capture devices provice lossless YUV2 capture mode 
		// RBG Data
		.red   ( ( win256 ) ? rgb_img[23-:8] : ( test_red   | overlay_red  ) ),
		.green ( ( win256 ) ? rgb_img[15-:8] : ( test_green | overlay_green) ),
		.blue  ( ( win256 ) ? rgb_img[ 7-:8] : ( test_blue  | overlay_blue ) ),
		// HDMI and DVI encoded video
		.hdmi_data( hdmi_data ),
		.dvi_data( dvi_data )
	);
		


    // DDR Regsiters
    logic hdmi_ck;
    logic hdmi_d0;
    logic hdmi_d1;
    logic hdmi_d2;
    
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),.INIT(1'b0),.SRTYPE("SYNC")) i_ddr_ck ( .Q(hdmi_ck),.C(hdmi_clk5),.CE(1'b1),.D1(hdmi_data[0]),.D2(hdmi_data[4]),.R(0),.S(0));
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),.INIT(1'b0),.SRTYPE("SYNC")) i_ddr_d0 ( .Q(hdmi_d0),.C(hdmi_clk5),.CE(1'b1),.D1(hdmi_data[1]),.D2(hdmi_data[5]),.R(0),.S(0));
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),.INIT(1'b0),.SRTYPE("SYNC")) i_ddr_d1 ( .Q(hdmi_d1),.C(hdmi_clk5),.CE(1'b1),.D1(hdmi_data[2]),.D2(hdmi_data[6]),.R(0),.S(0));
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),.INIT(1'b0),.SRTYPE("SYNC")) i_ddr_d2 ( .Q(hdmi_d2),.C(hdmi_clk5),.CE(1'b1),.D1(hdmi_data[3]),.D2(hdmi_data[7]),.R(0),.S(0));

    // LVDS Differential Drivers
        
    OBUFDS i_lvds_ck( .O(hdmi_ck_p), .OB(hdmi_ck_n), .I(hdmi_ck) );
    OBUFDS i_lvds_d0( .O(hdmi_d0_p), .OB(hdmi_d0_n), .I(hdmi_d0) );
    OBUFDS i_lvds_d1( .O(hdmi_d1_p), .OB(hdmi_d1_n), .I(hdmi_d1) );
    OBUFDS i_lvds_d2( .O(hdmi_d2_p), .OB(hdmi_d2_n), .I(hdmi_d2) );
 
endmodule
