
import FIFOF::*;
import GetPut::*;
import Connectable::*;
import ConnectalConfig::*;

import PcieDma::*;

interface Example;
   interface PciePins pcie;
endinterface

(* no_default_clock, no_default_reset *)
module mkExample#(Clock pci_sys_clk_p, Clock pci_sys_clk_n, Reset pci_sys_reset_n)(Example);

   PcieDma pcieDma <- mkPcieDma(pci_sys_clk_p, pci_sys_clk_n, pci_sys_reset_n);
   let clock = pcieDma.clock();
   let reset = pcieDma.reset();

   for (Integer channel = 0; channel < valueOf(NumChannels); channel = channel + 1) begin
      FIFOF#(MemDataF#(DataBusWidth)) buffer <- mkDualClockBramFIFOF(clock, reset, clock, reset);
      rule readDataRule;
	 PipeOut#(MemDataF#(DataBusWidth)) readPipe = pcieDma.readData[channel];
	 MemDataF#(DataBusWidth) md = readPipe.first();
	 readPipe.deq();
	 // insert code here to consume md
      endrule
      rule writeDataRule;
	 // placeholder code to produce md
	 // tag, first, and last are not checked by the library
	 MemDataF#(DataBusWidth) md = MemDataF {data: 'hdada, tag: 0, first: False, last: False};
	 PipeIn#(MemDataF#(DataBusWidth)) writePipe = pcieDma.writeData[channel];
	 writePipe.enq(md);
      endrule
   end

   interface pcie = pcieDma.pcie;

endmodule