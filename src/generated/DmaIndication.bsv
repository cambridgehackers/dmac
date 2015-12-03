package DmaIndication;

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
import ConnectalConfig::*;
import ConnectalMemory::*;
import Portal::*;
import CtrlMux::*;
import MemTypes::*;
import Pipe::*;
import HostInterface::*;
import LinkerLib::*;
import DmaController::*;
import Clocks::*;
import Vector::*;
import BuildVector::*;
import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Connectable::*;
import Probe::*;
import ConnectalConfig::*;
import Pipe::*;
import MemTypes::*;
import MemReadEngine::*;
import MemWriteEngine::*;
import HostInterface::*;




typedef struct {
    Bit#(32) objId;
    Bit#(32) base;
    Bit#(8) tag;
    Bit#(32) cycles;
} TransferToFpgaDone_Message deriving (Bits);

typedef struct {
    Bit#(32) objId;
    Bit#(32) base;
    Bit#(8) tag;
    Bit#(32) cycles;
} TransferFromFpgaDone_Message deriving (Bits);

// exposed wrapper portal interface
interface DmaIndicationInputPipes;
    interface PipeOut#(TransferToFpgaDone_Message) transferToFpgaDone_PipeOut;
    interface PipeOut#(TransferFromFpgaDone_Message) transferFromFpgaDone_PipeOut;

endinterface
interface DmaIndicationInput;
    interface PipePortal#(2, 0, SlaveDataBusWidth) portalIfc;
    interface DmaIndicationInputPipes pipes;
endinterface
interface DmaIndicationWrapperPortal;
    interface PipePortal#(2, 0, SlaveDataBusWidth) portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface DmaIndicationWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(DmaIndicationInputPipes,DmaIndication);
   module mkConnection#(DmaIndicationInputPipes pipes, DmaIndication ifc)(Empty);

    rule handle_transferToFpgaDone_request;
        let request <- toGet(pipes.transferToFpgaDone_PipeOut).get();
        ifc.transferToFpgaDone(request.objId, request.base, request.tag, request.cycles);
    endrule

    rule handle_transferFromFpgaDone_request;
        let request <- toGet(pipes.transferFromFpgaDone_PipeOut).get();
        ifc.transferFromFpgaDone(request.objId, request.base, request.tag, request.cycles);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkDmaIndicationInput(DmaIndicationInput);
    Vector#(2, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,TransferToFpgaDone_Message) transferToFpgaDone_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = transferToFpgaDone_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,TransferFromFpgaDone_Message) transferFromFpgaDone_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = transferFromFpgaDone_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(TransferToFpgaDone_Message)));
            1: return fromInteger(valueOf(SizeOf#(TransferFromFpgaDone_Message)));
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
    interface DmaIndicationInputPipes pipes;
        interface transferToFpgaDone_PipeOut = transferToFpgaDone_requestAdapter.out;
        interface transferFromFpgaDone_PipeOut = transferFromFpgaDone_requestAdapter.out;
    endinterface
endmodule

module mkDmaIndicationWrapperPortal#(DmaIndication ifc)(DmaIndicationWrapperPortal);
    let dut <- mkDmaIndicationInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface DmaIndicationWrapperMemPortalPipes;
    interface DmaIndicationInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkDmaIndicationWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(DmaIndicationWrapperMemPortalPipes);

  let dut <- mkDmaIndicationInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface DmaIndicationInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkDmaIndicationWrapper#(idType id, DmaIndication ifc)(DmaIndicationWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkDmaIndicationWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
interface DmaIndicationOutput;
    interface PipePortal#(0, 2, SlaveDataBusWidth) portalIfc;
    interface DmaController::DmaIndication ifc;
endinterface
interface DmaIndicationProxy;
    interface StdPortal portalIfc;
    interface DmaController::DmaIndication ifc;
endinterface

interface DmaIndicationOutputPipeMethods;
    interface PipeIn#(TransferToFpgaDone_Message) transferToFpgaDone;
    interface PipeIn#(TransferFromFpgaDone_Message) transferFromFpgaDone;

endinterface

interface DmaIndicationOutputPipes;
    interface DmaIndicationOutputPipeMethods methods;
    interface PipePortal#(0, 2, SlaveDataBusWidth) portalIfc;
endinterface

function Bit#(16) getDmaIndicationMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(TransferToFpgaDone_Message)));
            1: return fromInteger(valueOf(SizeOf#(TransferFromFpgaDone_Message)));
    endcase
endfunction

(* synthesize *)
module mkDmaIndicationOutputPipes(DmaIndicationOutputPipes);
    Vector#(2, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,TransferToFpgaDone_Message) transferToFpgaDone_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = transferToFpgaDone_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,TransferFromFpgaDone_Message) transferFromFpgaDone_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = transferFromFpgaDone_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface DmaIndicationOutputPipeMethods methods;
    interface transferToFpgaDone = transferToFpgaDone_responseAdapter.in;
    interface transferFromFpgaDone = transferFromFpgaDone_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getDmaIndicationMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkDmaIndicationOutput(DmaIndicationOutput);
    let indicationPipes <- mkDmaIndicationOutputPipes;
    interface DmaController::DmaIndication ifc;

    method Action transferToFpgaDone(Bit#(32) objId, Bit#(32) base, Bit#(8) tag, Bit#(32) cycles);
        indicationPipes.methods.transferToFpgaDone.enq(TransferToFpgaDone_Message {objId: objId, base: base, tag: tag, cycles: cycles});
        //$display("indicationMethod 'transferToFpgaDone' invoked");
    endmethod
    method Action transferFromFpgaDone(Bit#(32) objId, Bit#(32) base, Bit#(8) tag, Bit#(32) cycles);
        indicationPipes.methods.transferFromFpgaDone.enq(TransferFromFpgaDone_Message {objId: objId, base: base, tag: tag, cycles: cycles});
        //$display("indicationMethod 'transferFromFpgaDone' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(DmaIndicationOutput);
   function Bit#(16) portalMessageSize(DmaIndicationOutput p, Bit#(16) methodNumber);
      return getDmaIndicationMessageSize(methodNumber);
   endfunction
endinstance


interface DmaIndicationInverse;
    method ActionValue#(TransferToFpgaDone_Message) transferToFpgaDone;
    method ActionValue#(TransferFromFpgaDone_Message) transferFromFpgaDone;

endinterface

interface DmaIndicationInverter;
    interface DmaController::DmaIndication ifc;
    interface DmaIndicationInverse inverseIfc;
endinterface

instance Connectable#(DmaIndicationInverse, DmaIndicationOutputPipeMethods);
   module mkConnection#(DmaIndicationInverse in, DmaIndicationOutputPipeMethods out)(Empty);
    mkConnection(in.transferToFpgaDone, out.transferToFpgaDone);
    mkConnection(in.transferFromFpgaDone, out.transferFromFpgaDone);

   endmodule
endinstance

(* synthesize *)
module mkDmaIndicationInverter(DmaIndicationInverter);
    FIFOF#(TransferToFpgaDone_Message) fifo_transferToFpgaDone <- mkFIFOF();
    FIFOF#(TransferFromFpgaDone_Message) fifo_transferFromFpgaDone <- mkFIFOF();

    interface DmaController::DmaIndication ifc;

    method Action transferToFpgaDone(Bit#(32) objId, Bit#(32) base, Bit#(8) tag, Bit#(32) cycles);
        fifo_transferToFpgaDone.enq(TransferToFpgaDone_Message {objId: objId, base: base, tag: tag, cycles: cycles});
    endmethod
    method Action transferFromFpgaDone(Bit#(32) objId, Bit#(32) base, Bit#(8) tag, Bit#(32) cycles);
        fifo_transferFromFpgaDone.enq(TransferFromFpgaDone_Message {objId: objId, base: base, tag: tag, cycles: cycles});
    endmethod
    endinterface
    interface DmaIndicationInverse inverseIfc;

    method ActionValue#(TransferToFpgaDone_Message) transferToFpgaDone;
        fifo_transferToFpgaDone.deq;
        return fifo_transferToFpgaDone.first;
    endmethod
    method ActionValue#(TransferFromFpgaDone_Message) transferFromFpgaDone;
        fifo_transferFromFpgaDone.deq;
        return fifo_transferFromFpgaDone.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkDmaIndicationInverterV(DmaIndicationInverter);
    PutInverter#(TransferToFpgaDone_Message) inv_transferToFpgaDone <- mkPutInverter();
    PutInverter#(TransferFromFpgaDone_Message) inv_transferFromFpgaDone <- mkPutInverter();

    interface DmaController::DmaIndication ifc;

    method Action transferToFpgaDone(Bit#(32) objId, Bit#(32) base, Bit#(8) tag, Bit#(32) cycles);
        inv_transferToFpgaDone.mod.put(TransferToFpgaDone_Message {objId: objId, base: base, tag: tag, cycles: cycles});
    endmethod
    method Action transferFromFpgaDone(Bit#(32) objId, Bit#(32) base, Bit#(8) tag, Bit#(32) cycles);
        inv_transferFromFpgaDone.mod.put(TransferFromFpgaDone_Message {objId: objId, base: base, tag: tag, cycles: cycles});
    endmethod
    endinterface
    interface DmaIndicationInverse inverseIfc;

    method ActionValue#(TransferToFpgaDone_Message) transferToFpgaDone;
        let v <- inv_transferToFpgaDone.inverse.get;
        return v;
    endmethod
    method ActionValue#(TransferFromFpgaDone_Message) transferFromFpgaDone;
        let v <- inv_transferFromFpgaDone.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkDmaIndicationProxySynth#(Bit#(SlaveDataBusWidth) id)(DmaIndicationProxy);
  let dut <- mkDmaIndicationOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface DmaController::DmaIndication ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkDmaIndicationProxy#(idType id)(DmaIndicationProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkDmaIndicationProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: DmaIndication
