DMA Controller 
==============

Figure :ref:`Fig-DmaController shows the architecture of the DMA
Controller. It enables a user program to read data from DRAM on the PC
and stream it to user logic in the FPGA and to stream data from user
logic in the FPGA and write it to DRAM on the PC. The user application
on the PC may read or write the data in DRAM.

Up to TBD data channels are supported.

.. image:: DmaController.*

.. _Fig-DmaController: Dma Controller

Simulation
----------

The DMA Controller software API and hardware interfaces are portable across FPGAs and simulation.

.. image:: DmaSimulation.*

In simulation, the software process and simulator share memory via
mmap() and coordinate via request and response messages sent over a
unix socket.

Simulator integration is accomplished via Bluespec import "BDPI" and SystemVerilog "DPI-C".

Performance
-----------

Performance was measured on a PC with an Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz with a VC709 FPGA.

 * read bandwidth 2630.70 MB/s link utilization 74%
 * write bandwidth 3345.04 MB/s link utilization 94%

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
 * Verilator 3.878
 * Xilinx xsim

Installation Instructions
-------------------------

 * Install Bluespec 2014.07.A or newer
 * Install Vivado 2014.4 or 2015.2

If you previously installed connectal::

    sudo apt-get purge connectal fpgamake fpgajtag buildcache pciescan

To install into /usr/local::

    tar -zxvf dmac-15.10.4.tar.gz
    cd dmac-15.10.4
    make
    sudo make install

If you prefer to install into /usr::

    sudo make PREFIX=/usr


Building the Example
--------------------

Build the example using make::

    cd dmac-15.10.4/example; make

Running the Example
--------------------

To program the FPGA with the example design::

    cd dmac-15.10.4/example
    fpajtag mkExample.bit

The first time you use a system after the FPGA is programmed, you will have to reboot::

    sudo reboot

Now run the example::

    cd dmac-15.10.4/example
    LD_LIBRARY_PATH=/usr/local/lib ./testdma-vc709




