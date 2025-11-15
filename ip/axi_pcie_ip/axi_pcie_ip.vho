-- (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- (c) Copyright 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of AMD and is protected under U.S. and international copyright
-- and other intellectual property laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- AMD, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) AMD shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or AMD had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- AMD products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of AMD products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.
-- IP VLNV: xilinx.com:ip:axi_pcie:2.9
-- IP Revision: 14

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT axi_pcie_ip
  PORT (
    axi_aresetn : IN STD_LOGIC;
    user_link_up : OUT STD_LOGIC;
    axi_aclk_out : OUT STD_LOGIC;
    axi_ctl_aclk_out : OUT STD_LOGIC;
    mmcm_lock : OUT STD_LOGIC;
    interrupt_out : OUT STD_LOGIC;
    INTX_MSI_Request : IN STD_LOGIC;
    INTX_MSI_Grant : OUT STD_LOGIC;
    MSI_enable : OUT STD_LOGIC;
    MSI_Vector_Num : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    MSI_Vector_Width : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_awregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axi_wstrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_wlast : IN STD_LOGIC;
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_arid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_arregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_rdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rlast : OUT STD_LOGIC;
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_rready : IN STD_LOGIC;
    m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awvalid : OUT STD_LOGIC;
    m_axi_awready : IN STD_LOGIC;
    m_axi_awlock : OUT STD_LOGIC;
    m_axi_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_wdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axi_wstrb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_wlast : OUT STD_LOGIC;
    m_axi_wvalid : OUT STD_LOGIC;
    m_axi_wready : IN STD_LOGIC;
    m_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_bvalid : IN STD_LOGIC;
    m_axi_bready : OUT STD_LOGIC;
    m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_arvalid : OUT STD_LOGIC;
    m_axi_arready : IN STD_LOGIC;
    m_axi_arlock : OUT STD_LOGIC;
    m_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_rdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_rlast : IN STD_LOGIC;
    m_axi_rvalid : IN STD_LOGIC;
    m_axi_rready : OUT STD_LOGIC;
    pci_exp_txp : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    pci_exp_txn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    pci_exp_rxp : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    pci_exp_rxn : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    REFCLK : IN STD_LOGIC;
    s_axi_ctl_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_ctl_awvalid : IN STD_LOGIC;
    s_axi_ctl_awready : OUT STD_LOGIC;
    s_axi_ctl_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_ctl_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_ctl_wvalid : IN STD_LOGIC;
    s_axi_ctl_wready : OUT STD_LOGIC;
    s_axi_ctl_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_ctl_bvalid : OUT STD_LOGIC;
    s_axi_ctl_bready : IN STD_LOGIC;
    s_axi_ctl_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_ctl_arvalid : IN STD_LOGIC;
    s_axi_ctl_arready : OUT STD_LOGIC;
    s_axi_ctl_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_ctl_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_ctl_rvalid : OUT STD_LOGIC;
    s_axi_ctl_rready : IN STD_LOGIC 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : axi_pcie_ip
  PORT MAP (
    axi_aresetn => axi_aresetn,
    user_link_up => user_link_up,
    axi_aclk_out => axi_aclk_out,
    axi_ctl_aclk_out => axi_ctl_aclk_out,
    mmcm_lock => mmcm_lock,
    interrupt_out => interrupt_out,
    INTX_MSI_Request => INTX_MSI_Request,
    INTX_MSI_Grant => INTX_MSI_Grant,
    MSI_enable => MSI_enable,
    MSI_Vector_Num => MSI_Vector_Num,
    MSI_Vector_Width => MSI_Vector_Width,
    s_axi_awid => s_axi_awid,
    s_axi_awaddr => s_axi_awaddr,
    s_axi_awregion => s_axi_awregion,
    s_axi_awlen => s_axi_awlen,
    s_axi_awsize => s_axi_awsize,
    s_axi_awburst => s_axi_awburst,
    s_axi_awvalid => s_axi_awvalid,
    s_axi_awready => s_axi_awready,
    s_axi_wdata => s_axi_wdata,
    s_axi_wstrb => s_axi_wstrb,
    s_axi_wlast => s_axi_wlast,
    s_axi_wvalid => s_axi_wvalid,
    s_axi_wready => s_axi_wready,
    s_axi_bid => s_axi_bid,
    s_axi_bresp => s_axi_bresp,
    s_axi_bvalid => s_axi_bvalid,
    s_axi_bready => s_axi_bready,
    s_axi_arid => s_axi_arid,
    s_axi_araddr => s_axi_araddr,
    s_axi_arregion => s_axi_arregion,
    s_axi_arlen => s_axi_arlen,
    s_axi_arsize => s_axi_arsize,
    s_axi_arburst => s_axi_arburst,
    s_axi_arvalid => s_axi_arvalid,
    s_axi_arready => s_axi_arready,
    s_axi_rid => s_axi_rid,
    s_axi_rdata => s_axi_rdata,
    s_axi_rresp => s_axi_rresp,
    s_axi_rlast => s_axi_rlast,
    s_axi_rvalid => s_axi_rvalid,
    s_axi_rready => s_axi_rready,
    m_axi_awaddr => m_axi_awaddr,
    m_axi_awlen => m_axi_awlen,
    m_axi_awsize => m_axi_awsize,
    m_axi_awburst => m_axi_awburst,
    m_axi_awprot => m_axi_awprot,
    m_axi_awvalid => m_axi_awvalid,
    m_axi_awready => m_axi_awready,
    m_axi_awlock => m_axi_awlock,
    m_axi_awcache => m_axi_awcache,
    m_axi_wdata => m_axi_wdata,
    m_axi_wstrb => m_axi_wstrb,
    m_axi_wlast => m_axi_wlast,
    m_axi_wvalid => m_axi_wvalid,
    m_axi_wready => m_axi_wready,
    m_axi_bresp => m_axi_bresp,
    m_axi_bvalid => m_axi_bvalid,
    m_axi_bready => m_axi_bready,
    m_axi_araddr => m_axi_araddr,
    m_axi_arlen => m_axi_arlen,
    m_axi_arsize => m_axi_arsize,
    m_axi_arburst => m_axi_arburst,
    m_axi_arprot => m_axi_arprot,
    m_axi_arvalid => m_axi_arvalid,
    m_axi_arready => m_axi_arready,
    m_axi_arlock => m_axi_arlock,
    m_axi_arcache => m_axi_arcache,
    m_axi_rdata => m_axi_rdata,
    m_axi_rresp => m_axi_rresp,
    m_axi_rlast => m_axi_rlast,
    m_axi_rvalid => m_axi_rvalid,
    m_axi_rready => m_axi_rready,
    pci_exp_txp => pci_exp_txp,
    pci_exp_txn => pci_exp_txn,
    pci_exp_rxp => pci_exp_rxp,
    pci_exp_rxn => pci_exp_rxn,
    REFCLK => REFCLK,
    s_axi_ctl_awaddr => s_axi_ctl_awaddr,
    s_axi_ctl_awvalid => s_axi_ctl_awvalid,
    s_axi_ctl_awready => s_axi_ctl_awready,
    s_axi_ctl_wdata => s_axi_ctl_wdata,
    s_axi_ctl_wstrb => s_axi_ctl_wstrb,
    s_axi_ctl_wvalid => s_axi_ctl_wvalid,
    s_axi_ctl_wready => s_axi_ctl_wready,
    s_axi_ctl_bresp => s_axi_ctl_bresp,
    s_axi_ctl_bvalid => s_axi_ctl_bvalid,
    s_axi_ctl_bready => s_axi_ctl_bready,
    s_axi_ctl_araddr => s_axi_ctl_araddr,
    s_axi_ctl_arvalid => s_axi_ctl_arvalid,
    s_axi_ctl_arready => s_axi_ctl_arready,
    s_axi_ctl_rdata => s_axi_ctl_rdata,
    s_axi_ctl_rresp => s_axi_ctl_rresp,
    s_axi_ctl_rvalid => s_axi_ctl_rvalid,
    s_axi_ctl_rready => s_axi_ctl_rready
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file axi_pcie_ip.vhd when simulating
-- the core, axi_pcie_ip. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.



