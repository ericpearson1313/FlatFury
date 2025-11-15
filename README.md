# FlatFury

My xilinx Artix-7 dev system for PCIe devlopment. It uses a LiteFury mounted to a raspberry Pi5 with M.2 slot.
I've incorporated my standard HDMI video output. I've brought up the pcie interface
without drivers directly accessing via: lspci, setpci, pcimem commands.

This repo builds upon the LiteFury basis but with a greatly simplified flat file hierarchy.
Its all system verilog and integrates a PCIe core and PLL ip modules (ungenerated) along with
the core HDMI graphics and text output.

Looking at the Floorplan we can observe (yellow) the minimal AXI-PCIe 1x 5g core reported 15% LE utilization. 
The HDMI core (magneta) is quite tiny for its usefulness!

![min_axi_pcie](min_axi_pcie.png)



