package LoopbackControl;

import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Connectable::*;
import Clocks::*;
import FloatingPoint::*;
import Adapter::*;
import Leds::*;
import Vector::*;
import SpecialFIFOs::*;
import ConnectalMemory::*;
import Portal::*;
import CtrlMux::*;
import MemTypes::*;
import Pipe::*;
import HostInterface::*;
import LinkerLib::*;
import Interfaces::*;
import Vector::*;
import BuildVector::*;
import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Connectable::*;
import Pipe::*;
import MemTypes::*;
import MemReadEngine::*;
import MemWriteEngine::*;
import HostInterface::*;




typedef struct {
    Bool lb;
} Loopback_Message deriving (Bits);

typedef struct {
    Bit#(32) fb;
} Marker_Message deriving (Bits);

// exposed wrapper portal interface
interface LoopbackControlInputPipes;
    interface PipeOut#(Loopback_Message) loopback_PipeOut;
    interface PipeOut#(Marker_Message) marker_PipeOut;

endinterface
interface LoopbackControlInput;
    interface PipePortal#(2, 0, SlaveDataBusWidth) portalIfc;
    interface LoopbackControlInputPipes pipes;
endinterface
interface LoopbackControlWrapperPortal;
    interface PipePortal#(2, 0, SlaveDataBusWidth) portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface LoopbackControlWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(LoopbackControlInputPipes,LoopbackControl);
   module mkConnection#(LoopbackControlInputPipes pipes, LoopbackControl ifc)(Empty);

    rule handle_loopback_request;
        let request <- toGet(pipes.loopback_PipeOut).get();
        ifc.loopback(request.lb);
    endrule

    rule handle_marker_request;
        let request <- toGet(pipes.marker_PipeOut).get();
        ifc.marker(request.fb);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkLoopbackControlInput(LoopbackControlInput);
    Vector#(2, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,Loopback_Message) loopback_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = loopback_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,Marker_Message) marker_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = marker_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Loopback_Message)));
            1: return fromInteger(valueOf(SizeOf#(Marker_Message)));
            endcase
        endmethod
        endinterface
        interface Vector requests = requestPipeIn;
        interface Vector indications = nil;
        interface PortalInterrupt intr;
           method Bool status();
              return False;
           endmethod
           method Bit#(dataWidth) channel();
              return -1;
           endmethod
        endinterface
    endinterface
    interface LoopbackControlInputPipes pipes;
        interface loopback_PipeOut = loopback_requestAdapter.out;
        interface marker_PipeOut = marker_requestAdapter.out;
    endinterface
endmodule

module mkLoopbackControlWrapperPortal#(LoopbackControl ifc)(LoopbackControlWrapperPortal);
    let dut <- mkLoopbackControlInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface LoopbackControlWrapperMemPortalPipes;
    interface LoopbackControlInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkLoopbackControlWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(LoopbackControlWrapperMemPortalPipes);

  let dut <- mkLoopbackControlInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface LoopbackControlInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkLoopbackControlWrapper#(idType id, LoopbackControl ifc)(LoopbackControlWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkLoopbackControlWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
interface LoopbackControlOutput;
    interface PipePortal#(0, 2, SlaveDataBusWidth) portalIfc;
    interface Interfaces::LoopbackControl ifc;
endinterface
interface LoopbackControlProxy;
    interface StdPortal portalIfc;
    interface Interfaces::LoopbackControl ifc;
endinterface

interface LoopbackControlOutputPipeMethods;
    interface PipeIn#(Loopback_Message) loopback;
    interface PipeIn#(Marker_Message) marker;

endinterface

interface LoopbackControlOutputPipes;
    interface LoopbackControlOutputPipeMethods methods;
    interface PipePortal#(0, 2, SlaveDataBusWidth) portalIfc;
endinterface

function Bit#(16) getLoopbackControlMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Loopback_Message)));
            1: return fromInteger(valueOf(SizeOf#(Marker_Message)));
    endcase
endfunction

(* synthesize *)
module mkLoopbackControlOutputPipes(LoopbackControlOutputPipes);
    Vector#(2, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,Loopback_Message) loopback_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = loopback_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,Marker_Message) marker_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = marker_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface LoopbackControlOutputPipeMethods methods;
    interface loopback = loopback_responseAdapter.in;
    interface marker = marker_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getLoopbackControlMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkLoopbackControlOutput(LoopbackControlOutput);
    let indicationPipes <- mkLoopbackControlOutputPipes;
    interface Interfaces::LoopbackControl ifc;

    method Action loopback(Bool lb);
        indicationPipes.methods.loopback.enq(Loopback_Message {lb: lb});
        //$display("indicationMethod 'loopback' invoked");
    endmethod
    method Action marker(Bit#(32) fb);
        indicationPipes.methods.marker.enq(Marker_Message {fb: fb});
        //$display("indicationMethod 'marker' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(LoopbackControlOutput);
   function Bit#(16) portalMessageSize(LoopbackControlOutput p, Bit#(16) methodNumber);
      return getLoopbackControlMessageSize(methodNumber);
   endfunction
endinstance


interface LoopbackControlInverse;
    method ActionValue#(Loopback_Message) loopback;
    method ActionValue#(Marker_Message) marker;

endinterface

interface LoopbackControlInverter;
    interface Interfaces::LoopbackControl ifc;
    interface LoopbackControlInverse inverseIfc;
endinterface

instance Connectable#(LoopbackControlInverse, LoopbackControlOutputPipeMethods);
   module mkConnection#(LoopbackControlInverse in, LoopbackControlOutputPipeMethods out)(Empty);
    mkConnection(in.loopback, out.loopback);
    mkConnection(in.marker, out.marker);

   endmodule
endinstance

(* synthesize *)
module mkLoopbackControlInverter(LoopbackControlInverter);
    FIFOF#(Loopback_Message) fifo_loopback <- mkFIFOF();
    FIFOF#(Marker_Message) fifo_marker <- mkFIFOF();

    interface Interfaces::LoopbackControl ifc;

    method Action loopback(Bool lb);
        fifo_loopback.enq(Loopback_Message {lb: lb});
    endmethod
    method Action marker(Bit#(32) fb);
        fifo_marker.enq(Marker_Message {fb: fb});
    endmethod
    endinterface
    interface LoopbackControlInverse inverseIfc;

    method ActionValue#(Loopback_Message) loopback;
        fifo_loopback.deq;
        return fifo_loopback.first;
    endmethod
    method ActionValue#(Marker_Message) marker;
        fifo_marker.deq;
        return fifo_marker.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkLoopbackControlInverterV(LoopbackControlInverter);
    PutInverter#(Loopback_Message) inv_loopback <- mkPutInverter();
    PutInverter#(Marker_Message) inv_marker <- mkPutInverter();

    interface Interfaces::LoopbackControl ifc;

    method Action loopback(Bool lb);
        inv_loopback.mod.put(Loopback_Message {lb: lb});
    endmethod
    method Action marker(Bit#(32) fb);
        inv_marker.mod.put(Marker_Message {fb: fb});
    endmethod
    endinterface
    interface LoopbackControlInverse inverseIfc;

    method ActionValue#(Loopback_Message) loopback;
        let v <- inv_loopback.inverse.get;
        return v;
    endmethod
    method ActionValue#(Marker_Message) marker;
        let v <- inv_marker.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkLoopbackControlProxySynth#(Bit#(SlaveDataBusWidth) id)(LoopbackControlProxy);
  let dut <- mkLoopbackControlOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface Interfaces::LoopbackControl ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkLoopbackControlProxy#(idType id)(LoopbackControlProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkLoopbackControlProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: LoopbackControl
