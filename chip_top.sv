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
    assign pcie_mgt_txn  = 4'hz;
    assign pcie_mgt_txp  = 4'hz;    
    
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
    
    // Blink LEDs
    logic [26:0] blink_count;
    always_ff @(posedge sys_clk)  blink_count <= ( sys_reset ) ? 0 :blink_count + 1;
    assign LED_A1 = blink_count[26];
    assign LED_A2 = blink_count[25];
    assign LED_A3 = blink_count[24];
    
    
    ///////////////////////////
    //  AXI-PCIe Interface
    /////////////////////////// 
       
    // Output Interface Signals
    logic user_link_up;    
    logic axi_clk;    
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
    
    // PCI Clock Input buffer
    logic REFCLK;      
    IBUFDS_GTE2 IBUFDS_GTE2_inst (.I( pcie_clkin_clk_p ), .IB( pcie_clkin_clk_n ), .O( REFCLK ), .ODIV2( ), .CEB( 1'b0 ) );

    assign LED_A4       = user_link_up;
      
    axi_pcie_ip i_pcie (
        .REFCLK          ( REFCLK      ),
        .axi_aresetn     ( 1'b1         ),
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
        // Tied off for nowbit 
        .s_axi_awvalid ( 0 ), .s_axi_arvalid ( 0 ), .s_axi_wvalid( 0 ), .s_axi_rvalid(   ), .s_axi_bvalid(   ),
        .s_axi_awready (   ), .s_axi_arready (   ), .s_axi_wready(   ), .s_axi_rready( 0 ), .s_axi_bready( 0 ),
        .s_axi_awid    ( 0 ), .s_axi_arid    ( 0 ),                     .s_axi_rid   (   ), .s_axi_bid   (   ),
        .s_axi_awaddr  ( 0 ), .s_axi_araddr  ( 0 ), .s_axi_wdata ( 0 ), .s_axi_rdata (   ), .s_axi_bresp (   ),
        .s_axi_awlen   ( 0 ), .s_axi_arlen   ( 0 ), .s_axi_wlast ( 0 ), .s_axi_rlast (   ),
        .s_axi_awsize  ( 0 ), .s_axi_arsize  ( 0 ), .s_axi_wstrb ( 0 ), .s_axi_rresp (   ),
        .s_axi_awburst ( 0 ), .s_axi_arburst ( 0 ),
        .s_axi_awregion( 0 ), .s_axi_arregion( 0 ),
     
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
        .s_axi_ctl_awvalid ( 0 ), .s_axi_ctl_arvalid ( 0 ), .s_axi_ctl_wvalid( 0 ), .s_axi_ctl_rvalid(   ), .s_axi_ctl_bvalid(   ),
        .s_axi_ctl_awready (   ), .s_axi_ctl_arready (   ), .s_axi_ctl_wready(   ), .s_axi_ctl_rready( 0 ), .s_axi_ctl_bready( 0 ),
        .s_axi_ctl_awaddr  ( 0 ), .s_axi_ctl_araddr  ( 0 ), .s_axi_ctl_wdata ( 0 ), .s_axi_ctl_rdata (   ), .s_axi_ctl_bresp (   ),
                                                            .s_axi_ctl_wstrb ( 0 ), .s_axi_ctl_rresp (   )
    ); 
    
    
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
    
	// AXI Monitor, Log
	// queue last 8 tranascitons of each of AW, AR, R
	logic [7:0][39:0] aw_hex_reg, ar_hex_reg;
	logic [7:0][12:0] aw_bin_reg, ar_bin_reg;
	logic [7:0][63:0]  w_hex_reg;
	logic [7:0][63:0]  w_bin_reg;
	always_ff @(posedge axi_clk) begin
		aw_hex_reg <= ( m_axi_awvalid && m_axi_awready ) ? { aw_hex_reg[6:0], { m_axi_awaddr, m_axi_awlen }} : aw_hex_reg;
		aw_bin_reg <= ( m_axi_awvalid && m_axi_awready ) ? { aw_bin_reg[6:0], { m_axi_awsize, m_axi_awburst, m_axi_awprot, m_axi_awlock, m_axi_awcache }} : aw_bin_reg;
		ar_hex_reg <= ( m_axi_arvalid && m_axi_arready ) ? { ar_hex_reg[6:0], { m_axi_araddr, m_axi_arlen }} : ar_hex_reg;
		ar_bin_reg <= ( m_axi_arvalid && m_axi_arready ) ? { ar_bin_reg[6:0], { m_axi_arsize, m_axi_arburst, m_axi_arprot, m_axi_arlock, m_axi_arcache }} : ar_bin_reg;
		w_hex_reg  <= ( m_axi_wvalid  && m_axi_wready  ) ? { w_hex_reg[6:0] , { m_axi_wdata }} : w_hex_reg;
		w_bin_reg  <= ( m_axi_wvalid  && m_axi_wready  ) ? { w_bin_reg[6:0] , { m_axi_wstrb, m_axi_wlast }} : w_bin_reg;
	end
		    
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
		.green( test_green ),
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


	// AXI Log register live Overlay Generators
	logic [8:0] aw_ovl, ar_ovl, w_ovl;
	genvar gg;
	int row, col;
	generate
		for( gg = 0; gg < 10; gg++ ) begin : aw_text
			row = gg*2 + 10;
			col = 40;
			// AW Log Text Overlay
			if( gg == 0 ) begin : aw_title
				string_overlay #(.LEN(41 )) i_id0(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x(col+7 ), .y(row), .out( aw_ovl[gg] ), .str( "AW Address  Len Size Brst Prot Lock Cache" ) );
			end else if ( gg >= 2 ) begin : aw_fields
				hex_overlay    #(.LEN( 8 )) i_id1(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+10), .y(row), .out( aw_ovl[gg] ), .in( aw_hex_reg[gg-2][39-:32] ) );
				hex_overlay    #(.LEN( 2 )) i_id2(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+19), .y(row), .out( aw_ovl[gg] ), .in( aw_hex_reg[gg-2][ 7-:8 ] ) );
				bin_overlay    #(.LEN( 3 )) i_id3(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+23), .y(row), .out( aw_ovl[gg] ), .in( aw_bin_reg[gg-2][12-:3 ] ) );
				bin_overlay    #(.LEN( 2 )) i_id4(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+27), .y(row), .out( aw_ovl[gg] ), .in( aw_bin_reg[gg-2][ 9-:2 ] ) );
				bin_overlay    #(.LEN( 3 )) i_id5(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+32), .y(row), .out( aw_ovl[gg] ), .in( aw_bin_reg[gg-2][ 7-:3 ] ) );
				bin_overlay    #(.LEN( 1 )) i_id6(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+37), .y(row), .out( aw_ovl[gg] ), .in( aw_bin_reg[gg-2][ 4-:1 ] ) );
				bin_overlay    #(.LEN( 4 )) i_id7(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+42), .y(row), .out( aw_ovl[gg] ), .in( aw_bin_reg[gg-2][ 3-:4 ] ) );
			end
			// AR Log Text Overlay
			row = gg*2 + 10;
			col = 0;
			if( gg == 0 ) begin : ar_title
				string_overlay #(.LEN(41 )) i_id8(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x(col+7 ), .y(row), .out( ar_ovl[gg] ), .str( "AR Address  Len Size Brst Prot Lock Cache" ) );
			end else if ( gg >= 2 ) begin : ar_fields
				hex_overlay    #(.LEN( 8 )) i_id9(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+10), .y(row), .out( ar_ovl[gg] ), .in( ar_hex_reg[gg-2][39-:32] ) );
				hex_overlay    #(.LEN( 2 )) i_ida(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+19), .y(row), .out( ar_ovl[gg] ), .in( ar_hex_reg[gg-2][ 7-:8 ] ) );
				bin_overlay    #(.LEN( 3 )) i_idb(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+23), .y(row), .out( ar_ovl[gg] ), .in( ar_bin_reg[gg-2][12-:3 ] ) );
				bin_overlay    #(.LEN( 2 )) i_idc(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+27), .y(row), .out( ar_ovl[gg] ), .in( ar_bin_reg[gg-2][ 9-:2 ] ) );
				bin_overlay    #(.LEN( 3 )) i_idd(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+32), .y(row), .out( ar_ovl[gg] ), .in( ar_bin_reg[gg-2][ 7-:3 ] ) );
				bin_overlay    #(.LEN( 1 )) i_ide(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+37), .y(row), .out( ar_ovl[gg] ), .in( ar_bin_reg[gg-2][ 4-:1 ] ) );
				bin_overlay    #(.LEN( 4 )) i_idf(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+42), .y(row), .out( ar_ovl[gg] ), .in( ar_bin_reg[gg-2][ 3-:4 ] ) );
			end
			// W Log Text Overlay
			row = gg*2 + 10;
			col = 80;
			if( gg == 0 ) begin : ar_title
	            string_overlay #(.LEN(34 )) i_idg(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x(col+7 ), .y(row), .out(  w_ovl[gg] ), .str( " W Write Data        Strobe   Last" ) );
			end else if ( gg >= 2 ) begin : ar_fields
				hex_overlay    #(.LEN(16 )) i_idh(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x(col+10), .y(row), .out(  w_ovl[gg] ), .in( w_hex_reg[gg-2][63-:64] ) );
				bin_overlay    #(.LEN( 8 )) i_idi(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+27), .y(row), .out(  w_ovl[gg] ), .in( w_bin_reg[gg-2][ 8-:8 ] ) );
				bin_overlay    #(.LEN( 1 )) i_idj(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x(col+36), .y(row), .out(  w_ovl[gg] ), .in( w_bin_reg[gg-2][ 0-:1 ] ) );
			end
		end
	endgenerate


	// Overlay Text - Dynamic
	logic [31:0] id_str;
	
	string_overlay #(.LEN(29 )) _id0(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 20 ), .y( 1 ), .out( id_str[0]), .str( "HDMI WVGA output 800x480x60Hz" ) );
	string_overlay #(.LEN(14 )) _id0(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x( 20 ), .y( 3 ), .out( id_str[0]), .str( "PCIe Link Up =" ) );
    bin_overlay    #(.LEN(1  )) _id2(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x( 35 ), .y( 3 ), .out( id_str[2]), .in( user_link_up ) );
	

	// Mix overlays
	logic overlay;
	assign overlay = ( text_ovl && text_color == 0 ) | // normal text
						  (|id_str) | (|aw_ovl) | (|ar_ovl) | (|w_ovl); // OR of Reduction ORs!
	
	// Overlay Color
	logic [7:0] overlay_red, overlay_green, overlay_blue;
	assign { overlay_red, overlay_green, overlay_blue } =
			( overlay ) ? 24'hFFFFFF :
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
		.red   ( test_red   | overlay_red   ),
		.green ( test_green | overlay_green ),
		.blue  ( test_blue  | overlay_blue  ),
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
