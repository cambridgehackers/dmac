Building and Running the DMA Controller
=======================================

System Requirements
-------------------

This version was tested on Ubuntu 14.04 using bluesim and VC707 using
Bluespec 2015.05.beta1 and should also work with 2014.07.A. It was
tested with Vivado 2015.2 and should also work with 2014.4, 2015.1.

The DMA controller requires two device drivers, portalmem and
pcieportal. The source release includes DKMS sources so that the
driver will be compiled for the kernel that is in use on the machine
and will be automatically updated if the kernel is updated.

Simulators supported:

 * Bluesim

Installation Instructions
-------------------------

 * Install Bluespec 2014.07.A or newer
 * Install Vivado 2014.4 or 2015.2

If you previously installed connectal::

    sudo apt-get purge connectal fpgamake fpgajtag buildcache pciescan

Install build dependences::

    sudo apt-get install zlib1g-dev libusb-1.0-0-dev

To install into /usr/local::

    tar -zxvf dmac-16.04.1.tar.gz
    cd dmac-16.04.1
    make
    sudo make install

If you prefer to install into /usr::

    sudo make PREFIX=/usr

The driver adjusts PCIe bus parameters for performance. In order to do
so, the kernel requires the following kernel command line argument::

    pci=pcie_bus_perf

On machines using grub, this can be added to /etc/default/grub::

    GRUB_CMDLINE_LINUX="pci=pcie_bus_perf"

and then run::

    update-grub
    reboot



Building the Example
--------------------

Build the example using make::

    cd dmac-16.04.1/example; make

Running the Example
--------------------

To program the FPGA with the example design::

    cd dmac-16.04.1/example
    fpgajtag mkExample.bit

The first time you use a system after the FPGA is programmed, you will have to reboot::

    sudo reboot

Now run the example::

    cd dmac-16.04.1/example
    ./testdma-vc709


ConnectalProjectConfig.bsv
------------------------------

When you build the example, it copies
dmac/src/template/ConnectalProjectConfig.bsv to the example directory
if there is not already a copy.

Some of the parameters in this file may be changed in order to configure the DMA controller.

 * NumChannels (default 8)

   Specifies the number of DMA channels implemented by the controller. The maximum is 8, unless the interface names are updated.

 * DataBusWidth (default 128)

   Specifies the data width of the read and write pipes exported by
   the DMA controller. It may be changed to 128, 64, or 32, but
   performance for a single channel will be maximized at width 128.

 * MainClockPeriod (default 4ns)

   Specifies the clock period of the mkPcieDma.clock(). By default,
   this clock is the same as the user clock supplied by the Xilinx
   PCIe core.

   If it is changed, then the application logic may be run at a
   different speed, and SyncFIFOFs are interposed between the user
   logic and the PCIe core. This is likely to degrade performance but
   may be useful for development purposes.

PCIe Vendor and Device ID
-------------------------

The PCIe vendor ID and device ID is set to 1be7:c100.

This may be changed, but it currently needs to be updated in several files:

 * dmac/pciescan/pciescan.sh
 * dmac/src/pciecore.tcl
 * dmac/debian/dmac.udev
 * dmac/src/connectal/drivers/pcieportal/pcieportal.c
 * dmac/src/connectal/etc/udev/rules.d/99-pcieportal.rules
