# "Normal" constraints file- not early not late


###############################################################################
# DDR
###############################################################################
# Note: Most of the pins will be set in the constraints file created by MIG
set_property PACKAGE_PIN H19 [get_ports {sys_clk_clk_n}]
set_property PACKAGE_PIN J19 [get_ports {sys_clk_clk_p}]
set_property IOSTANDARD LVDS_25 [get_ports sys_clk_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports sys_clk_clk_n]

set_property PACKAGE_PIN M15 [get_ports {DDR3_addr[0]}]
set_property PACKAGE_PIN L21 [get_ports {DDR3_addr[1]}]
set_property PACKAGE_PIN J21 [get_ports {DDR3_addr[10]}]
set_property PACKAGE_PIN M22 [get_ports {DDR3_addr[11]}]
set_property PACKAGE_PIN K22 [get_ports {DDR3_addr[12]}]
set_property PACKAGE_PIN N18 [get_ports {DDR3_addr[13]}]
set_property PACKAGE_PIN N22 [get_ports {DDR3_addr[14]}]
set_property PACKAGE_PIN M16 [get_ports {DDR3_addr[2]}]
set_property PACKAGE_PIN L18 [get_ports {DDR3_addr[3]}]
set_property PACKAGE_PIN K21 [get_ports {DDR3_addr[4]}]
set_property PACKAGE_PIN M18 [get_ports {DDR3_addr[5]}]
set_property PACKAGE_PIN M21 [get_ports {DDR3_addr[6]}]
set_property PACKAGE_PIN N20 [get_ports {DDR3_addr[7]}]
set_property PACKAGE_PIN M20 [get_ports {DDR3_addr[8]}]
set_property PACKAGE_PIN N19 [get_ports {DDR3_addr[9]}]
set_property PACKAGE_PIN L19 [get_ports {DDR3_ba[0]}]
set_property PACKAGE_PIN J20 [get_ports {DDR3_ba[1]}]
set_property PACKAGE_PIN L20 [get_ports {DDR3_ba[2]}]
set_property PACKAGE_PIN K18 [get_ports {DDR3_cas_n}]
set_property PACKAGE_PIN J17 [get_ports {DDR3_ck_n[0]}]
set_property PACKAGE_PIN K17 [get_ports {DDR3_ck_p[0]}]
set_property PACKAGE_PIN H22 [get_ports {DDR3_cke[0]}]
set_property PACKAGE_PIN A19 [get_ports {DDR3_dm[0]}]
set_property PACKAGE_PIN G22 [get_ports {DDR3_dm[1]}]
set_property PACKAGE_PIN D19 [get_ports {DDR3_dq[0]}]
set_property PACKAGE_PIN B20 [get_ports {DDR3_dq[1]}]
set_property PACKAGE_PIN D20 [get_ports {DDR3_dq[10]}]
set_property PACKAGE_PIN E21 [get_ports {DDR3_dq[11]}]
set_property PACKAGE_PIN C22 [get_ports {DDR3_dq[12]}]
set_property PACKAGE_PIN D21 [get_ports {DDR3_dq[13]}]
set_property PACKAGE_PIN B22 [get_ports {DDR3_dq[14]}]
set_property PACKAGE_PIN D22 [get_ports {DDR3_dq[15]}]
set_property PACKAGE_PIN E19 [get_ports {DDR3_dq[2]}]
set_property PACKAGE_PIN A20 [get_ports {DDR3_dq[3]}]
set_property PACKAGE_PIN F19 [get_ports {DDR3_dq[4]}]
set_property PACKAGE_PIN C19 [get_ports {DDR3_dq[5]}]
set_property PACKAGE_PIN F20 [get_ports {DDR3_dq[6]}]
set_property PACKAGE_PIN C18 [get_ports {DDR3_dq[7]}]
set_property PACKAGE_PIN E22 [get_ports {DDR3_dq[8]}]
set_property PACKAGE_PIN G21 [get_ports {DDR3_dq[9]}]
set_property PACKAGE_PIN E18 [get_ports {DDR3_dqs_n[0]}]
set_property PACKAGE_PIN A21 [get_ports {DDR3_dqs_n[1]}]
set_property PACKAGE_PIN F18 [get_ports {DDR3_dqs_p[0]}]
set_property PACKAGE_PIN B21 [get_ports {DDR3_dqs_p[1]}]
set_property PACKAGE_PIN K19 [get_ports {DDR3_odt[0]}]
set_property PACKAGE_PIN H20 [get_ports {DDR3_ras_n}]
set_property PACKAGE_PIN K16 [get_ports {DDR3_reset_n}]
set_property PACKAGE_PIN L16 [get_ports {DDR3_we_n}]

set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[10]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[11]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[12]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[13]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[14]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[3]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[4]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[5]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[6]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[7]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[8]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[9]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ba[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ba[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ba[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_cas_n}]
#set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_ck_n[0]}]
#set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_ck_p[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ck_n[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ck_p[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_cke[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dm[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dm[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[10]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[11]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[12]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[13]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[14]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[15]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[3]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[4]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[5]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[6]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[7]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[8]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[9]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_dqs_n[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_dqs_n[1]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_dqs_p[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_dqs_p[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_odt[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ras_n}]
set_property IOSTANDARD LVCMOS15 [get_ports {DDR3_reset_n}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_we_n}]


###############################################################################
# PCIe
###############################################################################
# Applied in early.xdc

###############################################################################
# LEDs (4)
###############################################################################

set_property PACKAGE_PIN G3 [get_ports LED_A1]
set_property IOSTANDARD LVCMOS33 [get_ports LED_A1]
set_property PULLUP true [get_ports LED_A1]
set_property DRIVE 8 [get_ports LED_A1]

set_property PACKAGE_PIN H3 [get_ports LED_A2]
set_property IOSTANDARD LVCMOS33 [get_ports LED_A2]
set_property PULLUP true [get_ports LED_A2]
set_property DRIVE 8 [get_ports LED_A2]

set_property PACKAGE_PIN G4 [get_ports {LED_A3}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_A3}]
set_property PULLUP true [get_ports {LED_A3}]
set_property DRIVE 8 [get_ports {LED_A3}]

set_property PACKAGE_PIN H4 [get_ports {LED_A4}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_A4}]
set_property PULLUP true [get_ports {LED_A4}]
set_property DRIVE 8 [get_ports {LED_A4}]

###############################################################################
# M.2 LED signal
###############################################################################
set_property PACKAGE_PIN M1 [get_ports {LED_M2}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED_M2}]
set_property PULLUP true [get_ports {LED_M2}]
set_property DRIVE 8 [get_ports {LED_M2}]


###############################################################################
# SPI
###############################################################################
set_property PACKAGE_PIN P22 [get_ports {SPI_0_io0_io}]
set_property PACKAGE_PIN R22 [get_ports {SPI_0_io1_io}]
set_property PACKAGE_PIN P21 [get_ports {SPI_0_io2_io}]
set_property PACKAGE_PIN R21 [get_ports {SPI_0_io3_io}]

set_property IOSTANDARD LVCMOS33 [get_ports {SPI_0_io0_io}]
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_0_io1_io}]
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_0_io2_io}]
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_0_io3_io}]

set_property PACKAGE_PIN T19 [get_ports {real_spi_ss}]
set_property IOSTANDARD LVCMOS33 [get_ports {real_spi_ss}]

set_property PACKAGE_PIN T21 [get_ports {SPI_0_ss_i}]
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_0_ss_i}]

###############################################################################
# HDMI
###############################################################################

set_property PACKAGE_PIN W9  [get_ports {hdmi_d0_p}]
set_property PACKAGE_PIN Y8  [get_ports {hdmi_d1_p}]
set_property PACKAGE_PIN V9  [get_ports {hdmi_d2_p}]
set_property PACKAGE_PIN AB8 [get_ports {hdmi_ck_n}]
set_property PACKAGE_PIN Y9  [get_ports {hdmi_d0_n}]
set_property PACKAGE_PIN Y7  [get_ports {hdmi_d1_n}]
set_property PACKAGE_PIN V8  [get_ports {hdmi_d2_n}]

set_property IOSTANDARD LVDS_25 [get_ports {hdmi_ck_p}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_d0_p}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_d1_p}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_d2_p}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_ck_n}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_d0_n}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_d1_n}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_d2_n}]


###############################################################################
# Timing Constraints
###############################################################################

create_clock -period 5.000 -name sys_clk [get_ports sys_clk_clk_n]

###############################################################################
# Physical Constraints
###############################################################################

# Input reset is resynchronized within FPGA design as necessary
set_false_path -from [get_ports pci_reset]
set_false_path -from [get_clocks sys_clk] -to [get_clocks hdmi_clk_sys_pll]


###############################################################################
# Additional design / project settings
###############################################################################

# Power down on overtemp
set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]

# High-speed configuration so FPGA is up in time to negotiate with PCIe root complex
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN Div-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]


