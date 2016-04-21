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

