import Vector::*;
import Pipe::*;
import MemTypes::*;
import ConnectalConfig::*;

typedef 2 NumChannels;

interface DmaTopPins;
   // derived from pcie clock
   interface Clock clock;
   interface Reset reset;
   // data out to application logic
   interface Vector#(NumChannels,PipeOut#(MemDataF#(DataBusWidth))) readData;
   // data in from application logic
   interface Vector#(NumChannels,PipeIn#(MemDataF#(DataBusWidth)))  writeData;
endinterface
