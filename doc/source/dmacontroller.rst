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

Performance
-----------

Performance was measured on a PC with an Intel(R) Core(TM) i5-2320 CPU @ 3.00GHz with a VC709 FPGA.

 * read bandwidth 2630.70 MB/s link utilization 74%
 * write bandwidth 3345.04 MB/s link utilization 94%

System Requirements
-------------------

This version was tested on Ubuntu 14.04 using bluesim and VC707 using
Bluespec 2015.05.beta1 and should also work with 2014.07.A. It was
tested with Vivado 2015.2 and should also work with 2014.4.

The DMA controller requires the Connectal device driver to enable
software to connect to the DMA controller in the FPGA. There are
prebuilt connectal packages for Ubuntu 12.04 and 14.04 that contain
DKMS sources for the required device drivers.

Installation Instructions
-------------------------

 * Install Bluespec 2014.07.A or newer
 * Install Vivado 2014.4 or newer
 * Install connectal::

    sudo apt-add-repository ppa:jamey-hicks/connectal
    sudo apt-get update
    sudo apt-get install connectal



Building the Example
--------------------

Build the example using make::

    cd dmac; make

Running the Example
--------------------

To run the example::

    cd dmac/example
    fpajtag mkExample.bit
    LD_LIBRARY_PATH=. ./testdma-$(BOARD)



