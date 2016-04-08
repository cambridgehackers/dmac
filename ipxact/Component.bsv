`include "ConnectalProjectConfig.bsv"

import FIFOF::*;
import GetPut::*;
import Connectable::*;
import Vector::*;
import ConnectalConfig::*;
import MemTypes::*;
import Pipe::*;
import AxiStream::*;

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


//import PcieDma::*;
import DmaComponentPins::*;

interface Component;
   interface PciePins pcie;
endinterface

interface PcieDmaComponent;
   // derived from pcie clock
   interface Clock clock;
   interface Reset reset;
   // data out to application logic
   interface Vector#(NumChannels,AxiStreamMaster#(DataBusWidth)) toFpga;
   // data in from application logic
   interface Vector#(NumChannels,AxiStreamSlave#(DataBusWidth)) fromFpga;
   // pins
   interface PciePins pcie;
endinterface

`ifndef BOARD_bluesim
(* synthesize, no_default_clock, no_default_reset *)
`endif
module mkPcieDmaComponent
`ifndef BOARD_bluesim
   #(Clock pci_sys_clk_p, Clock pci_sys_clk_n, Reset pci_sys_reset_n)
`endif
   (PcieDmaComponent);
`ifndef BOARD_bluesim
   PcieTop#(DmaComponentPins) pcieTop <- mkPcieTop(pci_sys_clk_p, pci_sys_clk_n, pci_sys_reset_n);
`else
   BsimTop pcieTop <- mkBsimTop();
`endif

   interface clock = pcieTop.pins.clock;
   interface reset = pcieTop.pins.reset;
   interface toFpga = pcieTop.pins.toFpga;
   interface fromFpga = pcieTop.pins.fromFpga;
`ifndef BOARD_bluesim
   interface pcie = pcieTop.pcie;
`endif
endmodule


`ifndef BOARD_bluesim
(* no_default_clock, no_default_reset *)
`endif
module mkComponent
`ifndef BOARD_bluesim
#(Clock pci_sys_clk_p, Clock pci_sys_clk_n, Reset pci_sys_reset_n)
`endif
(Component);

   let pcieDma <- mkPcieDmaComponent(
`ifndef BOARD_bluesim
      pci_sys_clk_p, pci_sys_clk_n, pci_sys_reset_n
`endif
      );
   let clock = pcieDma.clock();
   let reset = pcieDma.reset();

   for (Integer channel = 0; channel < valueOf(NumChannels); channel = channel + 1) begin
      Reg#(Bit#(16)) iter <- mkReg(0, clocked_by clock, reset_by reset);
      rule toFpgaRule;
	 // PipeOut#(MemDataF#(DataBusWidth)) toFpgaPipe = pcieDma.toFpga[channel];
	 // MemDataF#(DataBusWidth) md = toFpgaPipe.first();
	 // toFpgaPipe.deq();
	 // insert code here to consume md
      endrule
      rule fromFpgaRule;
	 // placeholder code to produce md
	 // tag, first, and last are not checked by the library
	 // MemDataF#(DataBusWidth) md = MemDataF {data: ('hdada << 32) | (fromInteger(channel) << 16) | extend(iter),
	 // 					tag: 0, first: False, last: False};
	 // PipeIn#(MemDataF#(DataBusWidth)) fromFpgaPipe = pcieDma.fromFpga[channel];
	 // fromFpgaPipe.enq(md);
	 iter <= iter + 1;
      endrule
   end

   interface pcie = pcieDma.pcie;

endmodule