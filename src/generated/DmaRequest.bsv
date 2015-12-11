package DmaRequest;

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
    Bit#(16) burstLenBytes;
} WriteRequestSize_Message deriving (Bits);

typedef struct {
    Bit#(16) readRequestBytes;
} ReadRequestSize_Message deriving (Bits);

typedef struct {
    Bit#(32) objId;
    Bit#(32) base;
    Bit#(32) bytes;
    Bit#(8) tag;
} TransferToFpga_Message deriving (Bits);

typedef struct {
    Bit#(32) objId;
    Bit#(32) base;
    Bit#(32) bytes;
    Bit#(8) tag;
} TransferFromFpga_Message deriving (Bits);

// exposed wrapper portal interface
interface DmaRequestInputPipes;
    interface PipeOut#(WriteRequestSize_Message) writeRequestSize_PipeOut;
    interface PipeOut#(ReadRequestSize_Message) readRequestSize_PipeOut;
    interface PipeOut#(TransferToFpga_Message) transferToFpga_PipeOut;
    interface PipeOut#(TransferFromFpga_Message) transferFromFpga_PipeOut;

endinterface
interface DmaRequestInput;
    interface PipePortal#(4, 0, SlaveDataBusWidth) portalIfc;
    interface DmaRequestInputPipes pipes;
endinterface
interface DmaRequestWrapperPortal;
    interface PipePortal#(4, 0, SlaveDataBusWidth) portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface DmaRequestWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(DmaRequestInputPipes,DmaRequest);
   module mkConnection#(DmaRequestInputPipes pipes, DmaRequest ifc)(Empty);

    rule handle_writeRequestSize_request;
        let request <- toGet(pipes.writeRequestSize_PipeOut).get();
        ifc.writeRequestSize(request.burstLenBytes);
    endrule

    rule handle_readRequestSize_request;
        let request <- toGet(pipes.readRequestSize_PipeOut).get();
        ifc.readRequestSize(request.readRequestBytes);
    endrule

    rule handle_transferToFpga_request;
        let request <- toGet(pipes.transferToFpga_PipeOut).get();
        ifc.transferToFpga(request.objId, request.base, request.bytes, request.tag);
    endrule

    rule handle_transferFromFpga_request;
        let request <- toGet(pipes.transferFromFpga_PipeOut).get();
        ifc.transferFromFpga(request.objId, request.base, request.bytes, request.tag);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkDmaRequestInput(DmaRequestInput);
    Vector#(4, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,WriteRequestSize_Message) writeRequestSize_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = writeRequestSize_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,ReadRequestSize_Message) readRequestSize_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = readRequestSize_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,TransferToFpga_Message) transferToFpga_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[2] = transferToFpga_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,TransferFromFpga_Message) transferFromFpga_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[3] = transferFromFpga_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(WriteRequestSize_Message)));
            1: return fromInteger(valueOf(SizeOf#(ReadRequestSize_Message)));
            2: return fromInteger(valueOf(SizeOf#(TransferToFpga_Message)));
            3: return fromInteger(valueOf(SizeOf#(TransferFromFpga_Message)));
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
    interface DmaRequestInputPipes pipes;
        interface writeRequestSize_PipeOut = writeRequestSize_requestAdapter.out;
        interface readRequestSize_PipeOut = readRequestSize_requestAdapter.out;
        interface transferToFpga_PipeOut = transferToFpga_requestAdapter.out;
        interface transferFromFpga_PipeOut = transferFromFpga_requestAdapter.out;
    endinterface
endmodule

module mkDmaRequestWrapperPortal#(DmaRequest ifc)(DmaRequestWrapperPortal);
    let dut <- mkDmaRequestInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface DmaRequestWrapperMemPortalPipes;
    interface DmaRequestInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkDmaRequestWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(DmaRequestWrapperMemPortalPipes);

  let dut <- mkDmaRequestInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface DmaRequestInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkDmaRequestWrapper#(idType id, DmaRequest ifc)(DmaRequestWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkDmaRequestWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
interface DmaRequestOutput;
    interface PipePortal#(0, 4, SlaveDataBusWidth) portalIfc;
    interface DmaController::DmaRequest ifc;
endinterface
interface DmaRequestProxy;
    interface StdPortal portalIfc;
    interface DmaController::DmaRequest ifc;
endinterface

interface DmaRequestOutputPipeMethods;
    interface PipeIn#(WriteRequestSize_Message) writeRequestSize;
    interface PipeIn#(ReadRequestSize_Message) readRequestSize;
    interface PipeIn#(TransferToFpga_Message) transferToFpga;
    interface PipeIn#(TransferFromFpga_Message) transferFromFpga;

endinterface

interface DmaRequestOutputPipes;
    interface DmaRequestOutputPipeMethods methods;
    interface PipePortal#(0, 4, SlaveDataBusWidth) portalIfc;
endinterface

function Bit#(16) getDmaRequestMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(WriteRequestSize_Message)));
            1: return fromInteger(valueOf(SizeOf#(ReadRequestSize_Message)));
            2: return fromInteger(valueOf(SizeOf#(TransferToFpga_Message)));
            3: return fromInteger(valueOf(SizeOf#(TransferFromFpga_Message)));
    endcase
endfunction

(* synthesize *)
module mkDmaRequestOutputPipes(DmaRequestOutputPipes);
    Vector#(4, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,WriteRequestSize_Message) writeRequestSize_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = writeRequestSize_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,ReadRequestSize_Message) readRequestSize_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = readRequestSize_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,TransferToFpga_Message) transferToFpga_responseAdapter <- mkAdapterToBus();
    indicationPipes[2] = transferToFpga_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,TransferFromFpga_Message) transferFromFpga_responseAdapter <- mkAdapterToBus();
    indicationPipes[3] = transferFromFpga_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface DmaRequestOutputPipeMethods methods;
    interface writeRequestSize = writeRequestSize_responseAdapter.in;
    interface readRequestSize = readRequestSize_responseAdapter.in;
    interface transferToFpga = transferToFpga_responseAdapter.in;
    interface transferFromFpga = transferFromFpga_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getDmaRequestMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkDmaRequestOutput(DmaRequestOutput);
    let indicationPipes <- mkDmaRequestOutputPipes;
    interface DmaController::DmaRequest ifc;

    method Action writeRequestSize(Bit#(16) burstLenBytes);
        indicationPipes.methods.writeRequestSize.enq(WriteRequestSize_Message {burstLenBytes: burstLenBytes});
        //$display("indicationMethod 'writeRequestSize' invoked");
    endmethod
    method Action readRequestSize(Bit#(16) readRequestBytes);
        indicationPipes.methods.readRequestSize.enq(ReadRequestSize_Message {readRequestBytes: readRequestBytes});
        //$display("indicationMethod 'readRequestSize' invoked");
    endmethod
    method Action transferToFpga(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
        indicationPipes.methods.transferToFpga.enq(TransferToFpga_Message {objId: objId, base: base, bytes: bytes, tag: tag});
        //$display("indicationMethod 'transferToFpga' invoked");
    endmethod
    method Action transferFromFpga(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
        indicationPipes.methods.transferFromFpga.enq(TransferFromFpga_Message {objId: objId, base: base, bytes: bytes, tag: tag});
        //$display("indicationMethod 'transferFromFpga' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(DmaRequestOutput);
   function Bit#(16) portalMessageSize(DmaRequestOutput p, Bit#(16) methodNumber);
      return getDmaRequestMessageSize(methodNumber);
   endfunction
endinstance


interface DmaRequestInverse;
    method ActionValue#(WriteRequestSize_Message) writeRequestSize;
    method ActionValue#(ReadRequestSize_Message) readRequestSize;
    method ActionValue#(TransferToFpga_Message) transferToFpga;
    method ActionValue#(TransferFromFpga_Message) transferFromFpga;

endinterface

interface DmaRequestInverter;
    interface DmaController::DmaRequest ifc;
    interface DmaRequestInverse inverseIfc;
endinterface

instance Connectable#(DmaRequestInverse, DmaRequestOutputPipeMethods);
   module mkConnection#(DmaRequestInverse in, DmaRequestOutputPipeMethods out)(Empty);
    mkConnection(in.writeRequestSize, out.writeRequestSize);
    mkConnection(in.readRequestSize, out.readRequestSize);
    mkConnection(in.transferToFpga, out.transferToFpga);
    mkConnection(in.transferFromFpga, out.transferFromFpga);

   endmodule
endinstance

(* synthesize *)
module mkDmaRequestInverter(DmaRequestInverter);
    FIFOF#(WriteRequestSize_Message) fifo_writeRequestSize <- mkFIFOF();
    FIFOF#(ReadRequestSize_Message) fifo_readRequestSize <- mkFIFOF();
    FIFOF#(TransferToFpga_Message) fifo_transferToFpga <- mkFIFOF();
    FIFOF#(TransferFromFpga_Message) fifo_transferFromFpga <- mkFIFOF();

    interface DmaController::DmaRequest ifc;

    method Action writeRequestSize(Bit#(16) burstLenBytes);
        fifo_writeRequestSize.enq(WriteRequestSize_Message {burstLenBytes: burstLenBytes});
    endmethod
    method Action readRequestSize(Bit#(16) readRequestBytes);
        fifo_readRequestSize.enq(ReadRequestSize_Message {readRequestBytes: readRequestBytes});
    endmethod
    method Action transferToFpga(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
        fifo_transferToFpga.enq(TransferToFpga_Message {objId: objId, base: base, bytes: bytes, tag: tag});
    endmethod
    method Action transferFromFpga(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
        fifo_transferFromFpga.enq(TransferFromFpga_Message {objId: objId, base: base, bytes: bytes, tag: tag});
    endmethod
    endinterface
    interface DmaRequestInverse inverseIfc;

    method ActionValue#(WriteRequestSize_Message) writeRequestSize;
        fifo_writeRequestSize.deq;
        return fifo_writeRequestSize.first;
    endmethod
    method ActionValue#(ReadRequestSize_Message) readRequestSize;
        fifo_readRequestSize.deq;
        return fifo_readRequestSize.first;
    endmethod
    method ActionValue#(TransferToFpga_Message) transferToFpga;
        fifo_transferToFpga.deq;
        return fifo_transferToFpga.first;
    endmethod
    method ActionValue#(TransferFromFpga_Message) transferFromFpga;
        fifo_transferFromFpga.deq;
        return fifo_transferFromFpga.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkDmaRequestInverterV(DmaRequestInverter);
    PutInverter#(WriteRequestSize_Message) inv_writeRequestSize <- mkPutInverter();
    PutInverter#(ReadRequestSize_Message) inv_readRequestSize <- mkPutInverter();
    PutInverter#(TransferToFpga_Message) inv_transferToFpga <- mkPutInverter();
    PutInverter#(TransferFromFpga_Message) inv_transferFromFpga <- mkPutInverter();

    interface DmaController::DmaRequest ifc;

    method Action writeRequestSize(Bit#(16) burstLenBytes);
        inv_writeRequestSize.mod.put(WriteRequestSize_Message {burstLenBytes: burstLenBytes});
    endmethod
    method Action readRequestSize(Bit#(16) readRequestBytes);
        inv_readRequestSize.mod.put(ReadRequestSize_Message {readRequestBytes: readRequestBytes});
    endmethod
    method Action transferToFpga(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
        inv_transferToFpga.mod.put(TransferToFpga_Message {objId: objId, base: base, bytes: bytes, tag: tag});
    endmethod
    method Action transferFromFpga(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
        inv_transferFromFpga.mod.put(TransferFromFpga_Message {objId: objId, base: base, bytes: bytes, tag: tag});
    endmethod
    endinterface
    interface DmaRequestInverse inverseIfc;

    method ActionValue#(WriteRequestSize_Message) writeRequestSize;
        let v <- inv_writeRequestSize.inverse.get;
        return v;
    endmethod
    method ActionValue#(ReadRequestSize_Message) readRequestSize;
        let v <- inv_readRequestSize.inverse.get;
        return v;
    endmethod
    method ActionValue#(TransferToFpga_Message) transferToFpga;
        let v <- inv_transferToFpga.inverse.get;
        return v;
    endmethod
    method ActionValue#(TransferFromFpga_Message) transferFromFpga;
        let v <- inv_transferFromFpga.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkDmaRequestProxySynth#(Bit#(SlaveDataBusWidth) id)(DmaRequestProxy);
  let dut <- mkDmaRequestOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface DmaController::DmaRequest ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkDmaRequestProxy#(idType id)(DmaRequestProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkDmaRequestProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: DmaRequest
