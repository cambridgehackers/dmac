// Copyright (c) 2015 Quanta Research Cambridge, Inc.

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import ConnectalConfig::*;
import Vector            :: *;
import GetPut::*;
import Connectable::*;
import Portal            :: *;
import Top               :: *;
import HostInterface     :: *;
import Pipe::*;
import CnocPortal::*;
import MemTypes:: *;
import MMU:: *;
import MemServer:: *;
import MMURequest::*;
import MMUIndication::*;
import MemServerIndication::*;
import MemServerRequest::*;
import SimDma::*;
import IfcNames::*;
import BuildVector::*;

`include "ConnectalProjectConfig.bsv"

`ifdef PIN_TYPE_INCLUDE
import `PIN_TYPE_INCLUDE::*;
`endif
`ifdef PIN_TYPE
typedef `PIN_TYPE PinType;
`else
typedef Empty PinType;
`endif

interface XsimTop;
   interface PinType pins;
endinterface

interface XsimSource;
    method Action beat(Bit#(32) v);
endinterface
import "BVI" XsimSource =
module mkXsimSourceBVI#(Bit#(32) portal)(XsimSource);
    port portal = portal;
    method beat(beat) enable(en_beat);
    schedule (beat) C (beat);
endmodule
module mkXsimSource#(PortalMsgIndication indication)(Empty);
   let tmp <- mkXsimSourceBVI(indication.id);
   rule ind_dst_rdy;
      indication.message.deq();
      tmp.beat(indication.message.first());
   endrule
endmodule

interface MsgSinkR#(numeric type bytes_per_beat);
   method ActionValue#(Bit#(32)) beat();
endinterface

import "BVI" XsimSink =
module mkXsimSinkBVI#(Bit#(32) portal)(MsgSinkR#(4));
   port portal = portal;
   method beat beat() enable (EN_beat) ready (RDY_beat);
   schedule (beat) C (beat);
endmodule
module mkXsimSink#(PortalMsgRequest request)(Empty);
   let sink <- mkXsimSinkBVI(request.id);

   rule req_src_rdy;
      let beat <- sink.beat();
      request.message.enq(beat);
   endrule
endmodule

module mkXsimMemoryConnection#(PhysMemMaster#(addrWidth, dataWidth) master)(Empty)
   provisos (Mul#(TDiv#(dataWidth, 8), 8, dataWidth),
	     Mul#(TDiv#(dataWidth, 32), 32, dataWidth),
	     Add#(a__, TDiv#(DataBusWidth,8), TDiv#(dataWidth, 8)),
	     Mul#(TDiv#(dataWidth, 32), 4, TDiv#(dataWidth, 8)));
   PhysMemSlave#(addrWidth,dataWidth) slave <- mkSimDmaDmaMaster();
   mkConnection(master, slave);
endmodule

module mkXsimTop#(Clock derivedClock, Reset derivedReset)(XsimTop);

   Reg#(Bool) dumpstarted <- mkReg(False);
   rule startdump if (!dumpstarted);
      //$dumpfile("dump.vcd");
      //$dumpvars;
      $display("XsimTop starting");
      dumpstarted <= True;
   endrule
   XsimHost host <- mkXsimHost(derivedClock, derivedReset);
   let top <- mkCnocTop(
`ifdef IMPORT_HOSTIF
       host
`else
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
       derivedClock, derivedReset
`else
// otherwise no params
`endif
`endif
       );

   MMUIndicationOutput lMMUIndicationOutput <- mkMMUIndicationOutput;
   MMURequestInput lMMURequestInput <- mkMMURequestInput;
   MMU#(PhysAddrWidth) lMMU <- mkMMU(0,True, lMMUIndicationOutput.ifc);
   mkConnection(lMMURequestInput.pipes, lMMU.request);

   MemServerIndicationOutput lMemServerIndicationOutput <- mkMemServerIndicationOutput;
   MemServerRequestInput lMemServerRequestInput <- mkMemServerRequestInput;
   MemServer#(PhysAddrWidth,DataBusWidth,NumberOfMasters) lMemServer <- mkMemServer(top.readers, top.writers, cons(lMMU,nil), lMemServerIndicationOutput.ifc);
   mkConnection(lMemServerRequestInput.pipes, lMemServer.request);

   let lMMUIndicationOutputNoc <- mkPortalMsgIndication(extend(pack(PlatformIfcNames_MMUIndicationH2S)), lMMUIndicationOutput.portalIfc.indications, lMMUIndicationOutput.portalIfc.messageSize);
   let lMMURequestInputNoc <- mkPortalMsgRequest(extend(pack(PlatformIfcNames_MMURequestS2H)), lMMURequestInput.portalIfc.requests);
   let lMemServerIndicationOutputNoc <- mkPortalMsgIndication(extend(pack(PlatformIfcNames_MemServerIndicationH2S)), lMemServerIndicationOutput.portalIfc.indications, lMemServerIndicationOutput.portalIfc.messageSize);
   let lMemServerRequestInputNoc <- mkPortalMsgRequest(extend(pack(PlatformIfcNames_MemServerRequestS2H)), lMemServerRequestInput.portalIfc.requests);

   mapM_(mkXsimSink, append(top.requests, append(vec(lMMURequestInputNoc), vec(lMemServerRequestInputNoc))));
   mapM_(mkXsimSource, append(top.indications, append(vec(lMMUIndicationOutputNoc), vec(lMemServerIndicationOutputNoc))));
   mapM_(mkXsimMemoryConnection, lMemServer.masters);

`ifdef PIN_TYPE
   interface pins = top.pins;
`endif
endmodule
