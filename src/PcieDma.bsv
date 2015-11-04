
import Vector::*;
import Pipe::*;
import MemTypes::*;
import HostInterface::*;
`ifndef BOARD_bluesim
import PcieHost::*;
import PCIEWRAPPER3::*;
import PcieTop::*;
typedef PciewrapPci_exp#(8) PciePins;
`else
import BsimTop::*;
interface PciePins;
endinterface
`endif
import ConnectalBramFifo::*;
import ConnectalConfig::*;

import DmaTopPins::*;
import DmaController::*;

interface PcieDma;
   // derived from pcie clock
   interface Clock clock;
   interface Reset reset;
   // data out to application logic
   interface Vector#(NumChannels,PipeOut#(MemDataF#(DataBusWidth))) readData;
   // data in from application logic
   interface Vector#(NumChannels,PipeIn#(MemDataF#(DataBusWidth)))  writeData;
   // pins
   interface PciePins pcie;
endinterface

`ifndef BOARD_bluesim
(* synthesize, no_default_clock, no_default_reset *)
`endif
module mkPcieDma
`ifndef BOARD_bluesim
   #(Clock pci_sys_clk_p, Clock pci_sys_clk_n, Reset pci_sys_reset_n)
`endif
   (PcieDma);
`ifndef BOARD_bluesim
   PcieTop#(DmaTopPins) pcieTop <- mkPcieTop(pci_sys_clk_p, pci_sys_clk_n, pci_sys_reset_n);
`else
   BsimTop pcieTop <- mkBsimTop();
`endif

   interface clock = pcieTop.pins.clock;
   interface reset = pcieTop.pins.reset;
   interface readData = pcieTop.pins.readData;
   interface writeData = pcieTop.pins.writeData;
`ifndef BOARD_bluesim
   interface pcie = pcieTop.pcie;
`endif
endmodule

export MemTypes::*;
export ConnectalBramFifo::*;
export HostInterface::*;
export PciePins(..);
export PcieDma(..);
export mkPcieDma;
export DmaTopPins::*;
export Pipe::*;
