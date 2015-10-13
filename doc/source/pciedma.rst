Package PcieDma
===============

Typedefs and Structures
-----------------------

.. bsv:typedef:: DataBusWidth

   Width of data pipes, 128 bits for gen2 speeds.

.. bsv:struct:: MemDataF#(DataBusWidth)

   One beat of the payload of a physical or logical memory read or write request.

   .. bsv:field:: Bit#(DataBusWidth) data

      One data beat worth of data.

   .. bsv:field:: Bit#(MemTagSize) tag

      Indicates to which request this data beat belongs.

   .. bsv:field:: Bool first

      Indicates that this is the first data beat of a request.

   .. bsv:field:: Bool last

      Indicates that this is the last data beat of a request.

BSV Interface PcieDma
---------------------

.. bsv:interface:: PcieDma

   .. bsv:subinterface:: Clock clock

      The 250Mhz clock used for the external interfaces of the bsv:module::mkPcieDma module.

   .. bsv:subinterface:: Reset reset

      The corresponding reset used for the external interfaces of the bsv:module::mkPcieDma module.

   .. bsv:subinterface:: Vector#(NumChannels,PipeOut#(MemDataF#(DataBusWidth))) readData

      Transmits data read from DRAM, tagged by the request number.

   .. bsv:subinterface:: Vector#(NumChannels,PipeIn#(MemDataF#(DataBusWidth)))  writeData

      Receives data to be written to DRAM.

   .. bsv:subinterface:: PciePins pcie

      The PCIE pins to be exported to the top level of the design.

BSV Module mkPcieDma
--------------------

.. bsv:module:: mkPcieDma

   Implements a DMA controller connecting to the host via PCIe and exporting interface :bsv:interface:`PcieDma`.
