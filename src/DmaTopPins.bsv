import Vector::*;
import Pipe::*;
import MemTypes::*;

typedef 2 NumChannels;

// matches definition in HostInterface.bsv
`ifdef DataBusWidth
typedef `DataBusWidth DataBusWidth;
`else
typedef 64 DataBusWidth;
`endif

interface DmaTopPins;
   // derived from pcie clock
   interface Clock clock;
   interface Reset reset;
   // data out to application logic
   interface Vector#(NumChannels,PipeOut#(MemDataF#(DataBusWidth))) readData;
   // data in from application logic
   interface Vector#(NumChannels,PipeIn#(MemDataF#(DataBusWidth)))  writeData;
endinterface
