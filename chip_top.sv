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
    //input  wire [3:0]   pcie_mgt_rxn,
    //input  wire [3:0]   pcie_mgt_rxp,
    //output wire [3:0]   pcie_mgt_txn,
    //output wire [3:0]   pcie_mgt_txp,
   
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
    assign LED_A4 = 1'b0;
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


	// Overlay Text - Dynamic
	logic [31:0] id_str;
	string_overlay #(.LEN(18 )) _id0(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x('h48), .y('h09), .out( id_str[0]), .str( "HDMI Video output 800x480x60Hz" ) );
	hex_overlay    #(.LEN(12 )) _id1(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char)    , .x('h50), .y('d58), .out( id_str[1]), .in( 48'h0123456789ABC ) );
    bin_overlay    #(.LEN(1  )) _id2(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char)    , .x('h46), .y('h09), .out( id_str[2]), .in( 1'b1 ) );
	//string_overlay #(.LEN(14)) _id3(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x('d119),.y('d58), .out( id_str[3]), .str( "commit 0123abc" ) );
	//hex_overlay    #(.LEN(8 )) _id4(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('h50),.y('d54), .out( id_str[4]), .in( oppersec_latch[31:0] ) );
	//string_overlay #(.LEN(16)) _id5(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x('h48), .y('d56), .out( id_str[5]), .str( "Total Operations" ) );
	//string_overlay #(.LEN(14)) _id6(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x('h48), .y('d52), .out( id_str[6]), .str( "Operations/sec" ) );

	// Display two 512 bit message blocks and 256 bit output hash
	//hex_overlay #(.LEN(128)) _id7(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('d1 ), .y('d16), .out( id_str[7]), .in( ibuf[0] ) );
	//hex_overlay #(.LEN(128)) _id8(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('d1 ), .y('d18), .out( id_str[8]), .in( ibuf[1] ) );
	//hex_overlay #(.LEN(64 )) _id9(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('d1 ), .y('d20), .out( id_str[9]), .in( hash    ) );
	//hex_overlay #(.LEN(64 )) _id10(.clk(hdmi_clk),.reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('d1 ), .y('d22), .out( id_str[10]),.in( hash2    ) );
	//hex_overlay #(.LEN(64 )) _id11(.clk(hdmi_clk),.reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('d1 ), .y('d24), .out( id_str[11]),.in( hash_word  ) );
	//hex_overlay #(.LEN(64 )) _id12(.clk(hdmi_clk),.reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('d1 ), .y('d26), .out( id_str[12]),.in( difficulty  ) );
	
	//hex_overlay #(.LEN( 8 )) _id13(.clk(hdmi_clk),.reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('d68), .y('d20), .out( id_str[13]),.in( nonce_pipe[1]  ) );
	//hex_overlay #(.LEN( 8 )) _id14(.clk(hdmi_clk),.reset(reset), .char_x(char_x), .char_y(char_y),.hex_char(hex_char), .x('d68), .y('d24), .out( id_str[14]),.in( nonce ) );//nonce_pipe[2]  ) );
	//bin_overlay #(.LEN( 1 )) _id15(.clk(hdmi_clk),.reset(reset), .char_x(char_x), .char_y(char_y),.bin_char(bin_char), .x('d78), .y('d24), .out( id_str[15]),.in( hit  ) );

	//string_overlay #(.LEN(7)) _id16(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x('d68), .y('d20), .out( id_str[16]), .str( "1st SHA" ) );
	//string_overlay #(.LEN(7)) _id17(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x('d68), .y('d22), .out( id_str[17]), .str( "2nd SHA" ) );
	//string_overlay #(.LEN(10)) _id18(.clk(hdmi_clk), .reset(reset), .char_x(char_x), .char_y(char_y),.ascii_char(ascii_char), .x('d68), .y('d26), .out( id_str[18]), .str( "difficulty" ) );
	
	logic overlay;
	assign overlay = ( text_ovl && text_color == 0 ) | // normal text
						  (|id_str  ) ;
	
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
