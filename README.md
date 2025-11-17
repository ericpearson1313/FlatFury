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

Now is time to bring up the pcie hardware. It proved helpful to add logic to capture the last eight (8) PCIe AXI transactions,
on each of the AXI-AR, AXI-AW, AXI-W busses to be able to prove exact operation. The busses were wired with simple handshake
with all addr/data/ctl feilds ignored. Added logic to display the 3x8 axi bus capture buffers on HDMI. 

In a shell on the raspberry Pi, running the following command sequence allowed me to enabled the device BAR for access, 
and then do { double-word, word, byte } accesses of R-W-R transfers to the hardware for logging.
using the pcimem command (from https://github.com/billfarrow/pcimem) to do the actual to the device without a device driver.

    lspci
    lspci -n
    lspci -d 10ee:7021 -nvv
    sudo setpci -s 0001:01:00.0 COMMAND=0x2
    lspci -d 10ee:7021 -nvv
    sudo ./pcimem /sys/bus/pci/devices/0001\:01\:00.0/resource0 0x8 d 0x0123456789abcdef
    sudo ./pcimem /sys/bus/pci/devices/0001\:01\:00.0/resource0 0x4 w 0x12345678
    sudo ./pcimem /sys/bus/pci/devices/0001\:01\:00.0/resource0 0x1 b 0x12

After running the commands the HDMI display shows the 6 RA read address transactions and the 3 AW write address transactions
and the 3 associated W write data trasfers. All looks good (and note the watermark).

![pcie_awake](pcie_awake.jpg)



