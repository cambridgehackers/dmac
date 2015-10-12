
import Vector::*;
import Pipe::*;
import MemTypes::*;
import HostInterface::*;
import PcieHost::*;
import PCIEWRAPPER3::*;
import PcieTop::*;
import ConnectalBramFifo::*;

import DmaTopPins::*;
import DmaController::*;

typedef PciewrapPci_exp#(8) PciePins;

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

(* synthesize, no_default_clock, no_default_reset *)
module mkPcieDma#(Clock pci_sys_clk_p, Clock pci_sys_clk_n, Reset pci_sys_reset_n)(PcieDma);
   PcieTop#(DmaTopPins) pcieTop <- mkPcieTop(pci_sys_clk_p, pci_sys_clk_n,
					     /* unused */ pci_sys_clk_p, /* unused */pci_sys_clk_n, pci_sys_reset_n);

   interface clock = pcieTop.pins.clock;
   interface reset = pcieTop.pins.reset;
   interface readData = pcieTop.pins.readData;
   interface writeData = pcieTop.pins.writeData;
   interface pcie = pcieTop.pcie;
endmodule

export MemTypes::*;
export ConnectalBramFifo::*;
export HostInterface::*;
export PciePins(..);
export PcieDma(..);
export mkPcieDma;
export DmaTopPins::*;
export Pipe::*;
