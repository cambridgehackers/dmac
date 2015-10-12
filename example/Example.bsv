
import FIFOF::*;
import GetPut::*;
import Connectable::*;

import PcieDma::*;

interface Example;
   interface PciePins pcie;
endinterface

(* no_default_clock, no_default_reset *)
module mkExample#(Clock pci_sys_clk_p, Clock pci_sys_clk_n, Reset pci_sys_reset_n)(Example);

   let pcieDma <- mkPcieDma(pci_sys_clk_p, pci_sys_clk_n, pci_sys_reset_n);
   let clock = pcieDma.clock();
   let reset = pcieDma.reset();

   for (Integer channel = 0; channel < valueOf(NumChannels); channel = channel + 1) begin
      FIFOF#(MemDataF#(DataBusWidth)) buffer <- mkDualClockBramFIFOF(clock, reset, clock, reset);
      rule readDataRule;
	 let md <- toGet(pcieDma.readData[channel]).get();
      endrule
      rule writeDataRule;
	 let md = unpack(0);
	 pcieDma.writeData[channel].enq(md);
      endrule
   end

   interface pcie = pcieDma.pcie;

endmodule