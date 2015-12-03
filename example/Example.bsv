`include "ConnectalProjectConfig.bsv"

import FIFOF::*;
import GetPut::*;
import Connectable::*;
import ConnectalConfig::*;

import PcieDma::*;

interface Example;
   interface PciePins pcie;
endinterface

`ifndef BOARD_bluesim
(* no_default_clock, no_default_reset *)
`endif
module mkExample
`ifndef BOARD_bluesim
#(Clock pci_sys_clk_p, Clock pci_sys_clk_n, Reset pci_sys_reset_n)
`endif
(Example);

   PcieDma pcieDma <- mkPcieDma(
`ifndef BOARD_bluesim
      pci_sys_clk_p, pci_sys_clk_n, pci_sys_reset_n
`endif
      );
   let clock = pcieDma.clock();
   let reset = pcieDma.reset();

   for (Integer channel = 0; channel < valueOf(NumChannels); channel = channel + 1) begin
      Reg#(Bit#(16)) iter <- mkReg(0, clocked_by clock, reset_by reset);
      rule toFpgaRule;
	 PipeOut#(MemDataF#(DataBusWidth)) toFpgaPipe = pcieDma.toFpga[channel];
	 MemDataF#(DataBusWidth) md = toFpgaPipe.first();
	 toFpgaPipe.deq();
	 // insert code here to consume md
      endrule
      rule fromFpgaRule;
	 // placeholder code to produce md
	 // tag, first, and last are not checked by the library
	 MemDataF#(DataBusWidth) md = MemDataF {data: ('hdada << 32) | (fromInteger(channel) << 16) | extend(iter),
						tag: 0, first: False, last: False};
	 PipeIn#(MemDataF#(DataBusWidth)) fromFpgaPipe = pcieDma.fromFpga[channel];
	 fromFpgaPipe.enq(md);
	 iter <= iter + 1;
      endrule
   end

   interface pcie = pcieDma.pcie;

endmodule