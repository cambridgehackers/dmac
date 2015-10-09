#include "GeneratedTypes.h"

#ifndef NO_CPP_PORTAL_CODE

/************** Start of MemServerRequestWrapper CPP ***********/
#include "MemServerRequest.h"
int MemServerRequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int MemServerRequestaddrTrans_cb (  struct PortalInternal *p, const uint32_t sglId, const uint32_t offset ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->addrTrans ( sglId, offset);
    return 0;
};
int MemServerRequestsetTileState_cb (  struct PortalInternal *p, const TileControl tc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->setTileState ( tc);
    return 0;
};
int MemServerRequeststateDbg_cb (  struct PortalInternal *p, const ChannelType rc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->stateDbg ( rc);
    return 0;
};
int MemServerRequestmemoryTraffic_cb (  struct PortalInternal *p, const ChannelType rc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->memoryTraffic ( rc);
    return 0;
};
MemServerRequestCb MemServerRequest_cbTable = {
    MemServerRequestdisconnect_cb,
    MemServerRequestaddrTrans_cb,
    MemServerRequestsetTileState_cb,
    MemServerRequeststateDbg_cb,
    MemServerRequestmemoryTraffic_cb,
};

/************** Start of MMURequestWrapper CPP ***********/
#include "MMURequest.h"
int MMURequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MMURequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int MMURequestsglist_cb (  struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len ) {
    (static_cast<MMURequestWrapper *>(p->parent))->sglist ( sglId, sglIndex, addr, len);
    return 0;
};
int MMURequestregion_cb (  struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 ) {
    (static_cast<MMURequestWrapper *>(p->parent))->region ( sglId, barr12, index12, barr8, index8, barr4, index4, barr0, index0);
    return 0;
};
int MMURequestidRequest_cb (  struct PortalInternal *p, const SpecialTypeForSendingFd fd ) {
    (static_cast<MMURequestWrapper *>(p->parent))->idRequest ( fd);
    return 0;
};
int MMURequestidReturn_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMURequestWrapper *>(p->parent))->idReturn ( sglId);
    return 0;
};
int MMURequestsetInterface_cb (  struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId ) {
    (static_cast<MMURequestWrapper *>(p->parent))->setInterface ( interfaceId, sglId);
    return 0;
};
MMURequestCb MMURequest_cbTable = {
    MMURequestdisconnect_cb,
    MMURequestsglist_cb,
    MMURequestregion_cb,
    MMURequestidRequest_cb,
    MMURequestidReturn_cb,
    MMURequestsetInterface_cb,
};

/************** Start of MemServerIndicationWrapper CPP ***********/
#include "MemServerIndication.h"
int MemServerIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int MemServerIndicationaddrResponse_cb (  struct PortalInternal *p, const uint64_t physAddr ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->addrResponse ( physAddr);
    return 0;
};
int MemServerIndicationreportStateDbg_cb (  struct PortalInternal *p, const DmaDbgRec rec ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->reportStateDbg ( rec);
    return 0;
};
int MemServerIndicationreportMemoryTraffic_cb (  struct PortalInternal *p, const uint64_t words ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->reportMemoryTraffic ( words);
    return 0;
};
int MemServerIndicationerror_cb (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->error ( code, sglId, offset, extra);
    return 0;
};
MemServerIndicationCb MemServerIndication_cbTable = {
    MemServerIndicationdisconnect_cb,
    MemServerIndicationaddrResponse_cb,
    MemServerIndicationreportStateDbg_cb,
    MemServerIndicationreportMemoryTraffic_cb,
    MemServerIndicationerror_cb,
};

/************** Start of MMUIndicationWrapper CPP ***********/
#include "MMUIndication.h"
int MMUIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int MMUIndicationidResponse_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->idResponse ( sglId);
    return 0;
};
int MMUIndicationconfigResp_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->configResp ( sglId);
    return 0;
};
int MMUIndicationerror_cb (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->error ( code, sglId, offset, extra);
    return 0;
};
MMUIndicationCb MMUIndication_cbTable = {
    MMUIndicationdisconnect_cb,
    MMUIndicationidResponse_cb,
    MMUIndicationconfigResp_cb,
    MMUIndicationerror_cb,
};

/************** Start of DmaRequestWrapper CPP ***********/
#include "DmaRequest.h"
int DmaRequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<DmaRequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int DmaRequestburstLen_cb (  struct PortalInternal *p, const uint16_t burstLenBytes ) {
    (static_cast<DmaRequestWrapper *>(p->parent))->burstLen ( burstLenBytes);
    return 0;
};
int DmaRequestread_cb (  struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag ) {
    (static_cast<DmaRequestWrapper *>(p->parent))->read ( objId, base, bytes, tag);
    return 0;
};
int DmaRequestwrite_cb (  struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag ) {
    (static_cast<DmaRequestWrapper *>(p->parent))->write ( objId, base, bytes, tag);
    return 0;
};
DmaRequestCb DmaRequest_cbTable = {
    DmaRequestdisconnect_cb,
    DmaRequestburstLen_cb,
    DmaRequestread_cb,
    DmaRequestwrite_cb,
};

/************** Start of LoopbackControlWrapper CPP ***********/
#include "LoopbackControl.h"
int LoopbackControldisconnect_cb (struct PortalInternal *p) {
    (static_cast<LoopbackControlWrapper *>(p->parent))->disconnect();
    return 0;
};
int LoopbackControlloopback_cb (  struct PortalInternal *p, const int lb ) {
    (static_cast<LoopbackControlWrapper *>(p->parent))->loopback ( lb);
    return 0;
};
int LoopbackControlmarker_cb (  struct PortalInternal *p, const uint32_t fb ) {
    (static_cast<LoopbackControlWrapper *>(p->parent))->marker ( fb);
    return 0;
};
LoopbackControlCb LoopbackControl_cbTable = {
    LoopbackControldisconnect_cb,
    LoopbackControlloopback_cb,
    LoopbackControlmarker_cb,
};

/************** Start of DmaIndicationWrapper CPP ***********/
#include "DmaIndication.h"
int DmaIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<DmaIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int DmaIndicationreadDone_cb (  struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles ) {
    (static_cast<DmaIndicationWrapper *>(p->parent))->readDone ( objId, base, tag, cycles);
    return 0;
};
int DmaIndicationwriteDone_cb (  struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles ) {
    (static_cast<DmaIndicationWrapper *>(p->parent))->writeDone ( objId, base, tag, cycles);
    return 0;
};
DmaIndicationCb DmaIndication_cbTable = {
    DmaIndicationdisconnect_cb,
    DmaIndicationreadDone_cb,
    DmaIndicationwriteDone_cb,
};
#endif //NO_CPP_PORTAL_CODE
