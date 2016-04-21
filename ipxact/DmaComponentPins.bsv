import Vector::*;
import Pipe::*;
import MemTypes::*;
import ConnectalConfig::*;
import AxiStream::*;

`include "ConnectalProjectConfig.bsv"
typedef `NumChannels NumChannels;

interface DmaComponentPins;
   // derived from pcie clock
   interface Clock clock;
   interface Reset reset;
   // data out to application logic
   interface Vector#(NumChannels,AxiStreamMaster#(DataBusWidth)) toFpga;
   // data in from application logic
   interface Vector#(NumChannels,AxiStreamSlave#(DataBusWidth))  fromFpga;
endinterface
