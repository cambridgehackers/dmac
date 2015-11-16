`define NumChannels 2
`define BurstLenSize 11

`define MemTagSize 6
`define ConnectalVersion 15.10.3
`define NumberOfMasters 1
`define PinType DmaTopPins
`define PinTypeInclude DmaTopPins
`define NumberOfUserTiles 1
`define SlaveDataBusWidth 32
`define SlaveControlAddrWidth 5
`define ExportType 
`define USE_DUAL_CLOCK_FIFOF 
`define DataBusWidth 128
`define project_dir $(DTOP)
`define MainClockPeriod 4
`define DerivedClockPeriod 4.000000
`define PcieClockPeriod 4
`define XILINX 1
`define MEMENGINE_REQUEST_CYCLES
  `define PhysAddrWidth 40
`ifndef BOARD_bluesim
  `define Virtex7 
  `define PCIE 
  `define PCIE3 
  `define PcieHostInterface 
  `define NUMBER_OF_LEDS 8
  `define PcieLanes 8
  `define BOARD_vc709 
`else
  `define SIMULATION
  `define BsimHostInterface
`endif

