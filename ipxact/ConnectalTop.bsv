
import Vector::*;
import BuildVector::*;
import Pipe::*;
import Portal::*;
import CtrlMux::*;
import HostInterface::*;
import AxiStream::*;
import Connectable::*;
import MemReadEngine::*;
import MemWriteEngine::*;
import MemTypes::*;
import MemServer::*;
import Pipe::*;
import IfcNames::*;
import DmaController::*;
import DmaIndication::*;
import DmaRequest::*;
import ConnectalConfig::*;
`include "ConnectalProjectConfig.bsv"
import `PinTypeInclude::*;


(* synthesize *)
module mkConnectalTop(ConnectalTop);
   Clock defaultClock <- exposeCurrentClock();
   Reset defaultReset <- exposeCurrentReset();

   function Bit#(SlaveDataBusWidth) indicationId(Integer i); return extend(pack(IfcNames_DmaIndicationH2S0)+fromInteger(i)); endfunction
   Vector#(NumChannels,DmaIndicationProxy) dmaIndicationProxies <- mapM(mkDmaIndicationProxy, genWith(indicationId));

   function DmaIndication getIfc(DmaIndicationProxy o); return o.ifc; endfunction
   DmaController#(NumChannels) dmaController <- mkDmaController(map(getIfc, dmaIndicationProxies));

   function Bit#(SlaveDataBusWidth) requestId(Integer i); return extend(pack(IfcNames_DmaRequestS2H0)+fromInteger(i)); endfunction
   Vector#(NumChannels,DmaRequestWrapper) dmaRequestWrappers <- mapM(uncurry(mkDmaRequestWrapper), zip(genWith(requestId), dmaController.request));

   function StdPortal indicationProxyPortalIfc(DmaIndicationProxy p); return p.portalIfc; endfunction
   function StdPortal requestWrapperPortalIfc(DmaRequestWrapper p); return p.portalIfc; endfunction
   let portals = append(map(indicationProxyPortalIfc, dmaIndicationProxies), map(requestWrapperPortalIfc, dmaRequestWrappers));
   let ctrl_mux <- mkSlaveMux(portals);
   Vector#(NumWriteClients,MemWriteClient#(DataBusWidth)) nullWriters = replicate(null_mem_write_client());
   Vector#(NumReadClients,MemReadClient#(DataBusWidth)) nullReaders = replicate(null_mem_read_client());

   Vector#(NumChannels,AxiStreamMaster#(DataBusWidth)) toFpga   <- mapM(mkAxiStreamMaster, dmaController.toFpga);
   Vector#(NumChannels,AxiStreamSlave#(DataBusWidth))  fromFpga <- mapM(mkAxiStreamSlave, dmaController.fromFpga);

   interface interrupt = getInterruptVector(portals);
   interface slave = ctrl_mux;
   interface readers = take(append(dmaController.readClient, nullReaders));
   interface writers = take(append(dmaController.writeClient, nullWriters));
   interface `PinType pins;
      interface clock = defaultClock;
      interface reset = defaultReset;
      interface toFpga = toFpga;
      interface fromFpga = fromFpga;
   endinterface

endmodule : mkConnectalTop
export mkConnectalTop;
export `PinTypeInclude::*;
