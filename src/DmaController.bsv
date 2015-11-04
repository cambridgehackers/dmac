// Copyright (c) 2015 Connectal Project

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

import Clocks::*;
import Vector::*;
import BuildVector::*;
import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Connectable::*;

import ConnectalConfig::*;
import Pipe::*;
import MemTypes::*;
import MemReadEngine::*;
import MemWriteEngine::*;
import HostInterface::*;
`include "ConnectalProjectConfig.bsv"

interface DmaRequest;
   //
   // Configures burstLen used by DMA transfers. Only needed for performance tuning if default value does not perform well.
   //
   method Action burstLen(Bit#(16) burstLenBytes);
   //
   // Requests a read of system memory, streaming the data to the readData PipeOut
   // @param objId the reference to the memory object allocated by portalAlloc
   // @param base  offset, in bytes, from which to start reading
   // @param bytes number of bytes to read, must be a multiple of the buswidth in bytes
   // @param tag   identifier for the request
   method Action read(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
   //
   // Requests a write of system memory, streaming the data from writeData PipeIn
   // @param objId the reference to the memory object allocated by portalAlloc
   // @param base  offset, in bytes, to which to start writing
   // @param bytes number of bytes to write, must be a multiple of the buswidth in bytes
   // @param tag   identifier for the request
   method Action write(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
endinterface

interface DmaIndication;
   // Indicates completion of read request, identified by tag, from offset base of objId
   method Action readDone(Bit#(32) objId, Bit#(32) base, Bit#(8) tag, Bit#(32) cycles);
   // Indicates completion of write request, identified by tag, to offset base of objId
   method Action writeDone(Bit#(32) objId, Bit#(32) base, Bit#(8) tag, Bit#(32) cycles);
endinterface

//
// DmaController controls multiple channels of DMA to/from system memory
// @param numChannels: the maximum number of simultaneous read and write streams
interface DmaController#(numeric type numChannels);
   // request from software
   interface Vector#(numChannels,DmaRequest) request;
   // data out to application logic
   interface Vector#(numChannels,PipeOut#(MemDataF#(DataBusWidth))) readData;
   // data in from application logic
   interface Vector#(numChannels,PipeIn#(MemDataF#(DataBusWidth)))  writeData;
   // memory interfaces connected to MemServer
   interface Vector#(1,MemReadClient#(DataBusWidth))      readClient;
   interface Vector#(1,MemWriteClient#(DataBusWidth))     writeClient;
endinterface

typedef 15 NumOutstandingRequests;
typedef TMul#(NumOutstandingRequests,TMul#(32,4)) BufferSizeBytes;

function Bit#(dsz) memdatafToData(MemDataF#(dsz) mdf); return mdf.data; endfunction

module mkDmaController#(Vector#(numChannels,DmaIndication) indication)(DmaController#(numChannels))
   provisos (Add#(1, a__, numChannels),
	     Add#(b__, TLog#(numChannels), TAdd#(1, TLog#(TMul#(NumOutstandingRequests, numChannels)))),
	     Add#(c__, TLog#(numChannels), 6), // why is this?
	     Add#(d__, TLog#(numChannels), TLog#(TMul#(NumOutstandingRequests, numChannels)))
	     );
   MemReadEngine#(DataBusWidth,DataBusWidth,NumOutstandingRequests,numChannels)  re <- mkMemReadEngineBuff(valueOf(BufferSizeBytes));
   MemWriteEngine#(DataBusWidth,DataBusWidth,NumOutstandingRequests,numChannels) we <- mkMemWriteEngineBuff(valueOf(BufferSizeBytes));

   Vector#(numChannels, FIFO#(MemengineCmd)) readCmds <- replicateM(mkSizedFIFO(valueOf(NumOutstandingRequests)));
   Vector#(numChannels, FIFO#(MemengineCmd)) writeCmds <- replicateM(mkSizedFIFO(valueOf(NumOutstandingRequests)));

   Vector#(numChannels, FIFO#(Tuple3#(Bit#(32),Bit#(32),Bit#(32)))) readReqs <- replicateM(mkSizedFIFO(valueOf(NumOutstandingRequests)));
   Vector#(numChannels, FIFO#(Tuple3#(Bit#(32),Bit#(32),Bit#(32)))) writeReqs <- replicateM(mkSizedFIFO(valueOf(NumOutstandingRequests)));
   Vector#(numChannels, FIFOF#(MemDataF#(DataBusWidth))) readFifo <- replicateM(mkFIFOF());
   Vector#(numChannels, FIFO#(Bit#(8))) writeTags <- replicateM(mkSizedFIFO(valueOf(NumOutstandingRequests)));
   Reg#(Bit#(BurstLenSize)) burstLenReg <- mkReg(64);
   Reg#(Bit#(32)) cyclesReg <- mkReg(0);
   rule countCycles;
      cyclesReg <= cyclesReg + 1;
   endrule

   for (Integer channel = 0; channel < valueOf(numChannels); channel = channel + 1) begin
       FIFO#(Bit#(8)) readTags <- mkSizedFIFO(valueOf(NumOutstandingRequests));

      rule readReqRule;
	 let cmd <- toGet(readCmds[channel]).get();
	 readReqs[channel].enq(tuple3(cmd.sglId, cmd.base, cyclesReg));
	 re.readServers[channel].request.put(cmd);
      endrule
       rule readDataRule;
	  let mdf <- toGet(re.readServers[channel].data).get();
	  if (mdf.last)
	     readTags.enq(extend(mdf.tag));
	  readFifo[channel].enq(mdf);
       endrule
       rule readDoneRule;
	  match { .objId, .base, .cycles } <- toGet(readReqs[channel]).get();
	  cycles = cycles - cyclesReg;
`ifdef MEMENGINE_REQUEST_CYCLES
	  let tagcycles <- toGet(re.readServers[channel].requestCycles).get();
	  cycles = tagcycles.cycles;
`endif
	  let tag <- toGet(readTags).get();
	  indication[channel].readDone(objId, base, tag, cycles);
       endrule
      rule writeReqRule;
	 let cmd <- toGet(writeCmds[channel]).get();
	 writeReqs[channel].enq(tuple3(cmd.sglId, cmd.base, cyclesReg));
	 we.writeServers[channel].request.put(cmd);
	 writeTags[channel].enq(extend(cmd.tag));
      endrule
       rule writeDoneRule;
	  match { .objId, .base, .cycles } <- toGet(writeReqs[channel]).get();
	  cycles = cycles - cyclesReg;
`ifdef MEMENGINE_REQUEST_CYCLES
	  let tagcycles <- toGet(we.writeServers[channel].requestCycles).get();
	  cycles = tagcycles.cycles;
`endif
	  let done <- we.writeServers[channel].done.get();
	  let tag <- toGet(writeTags[channel]).get();
	  indication[channel].writeDone(objId, base, tag, cycles);
       endrule
   end

   function DmaRequest dmaRequestInterface(Integer channel);
      return (interface DmaRequest;
	 method Action burstLen(Bit#(16) burstLenBytes);
	      burstLenReg <= truncate(burstLenBytes);
	 endmethod
	 method Action read(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
	      readCmds[channel].enq(MemengineCmd {sglId: truncate(objId),
						  base: extend(base),
						  burstLen: extend(burstLenReg),
						  len: bytes,
						  tag: truncate(tag)
						  });
	 endmethod
	 method Action write(Bit#(32) objId, Bit#(32) base, Bit#(32) bytes, Bit#(8) tag);
	    writeCmds[channel].enq(MemengineCmd {sglId: truncate(objId),
						 base: extend(base),
						 burstLen: extend(burstLenReg),
						 len: bytes,
						 tag: truncate(tag)
						 });
	 endmethod
	 endinterface);
   endfunction
   function PipeIn#(Bit#(dsz)) writeServerData(MemWriteEngineServer#(dsz) s); return s.data; endfunction

   interface Vector request = genWith(dmaRequestInterface);
   interface readClient = vec(re.dmaClient);
   interface writeClient = vec(we.dmaClient);
   interface readData = map(toPipeOut,readFifo);
   interface writeData = map(mapPipeIn(memdatafToData), map(writeServerData, we.writeServers));
endmodule
