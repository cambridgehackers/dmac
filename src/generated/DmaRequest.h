#include "GeneratedTypes.h"
#ifndef _DMAREQUEST_H_
#define _DMAREQUEST_H_
#include "portal.h"

class DmaRequestProxy : public Portal {
    DmaRequestCb *cb;
public:
    DmaRequestProxy(int id, int tile = DEFAULT_TILE, DmaRequestCb *cbarg = &DmaRequestProxyReq, int bufsize = DmaRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    DmaRequestProxy(int id, PortalTransportFunctions *item, void *param, DmaRequestCb *cbarg = &DmaRequestProxyReq, int bufsize = DmaRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, item, param, this, poller), cb(cbarg) {};
    DmaRequestProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, DmaRequest_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&DmaRequestProxyReq) {};
    int burstLen ( const uint16_t burstLenBytes ) { return cb->burstLen (&pint, burstLenBytes); };
    int transferToFpga ( const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag ) { return cb->transferToFpga (&pint, objId, base, bytes, tag); };
    int transferFromFpga ( const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag ) { return cb->transferFromFpga (&pint, objId, base, bytes, tag); };
};

extern DmaRequestCb DmaRequest_cbTable;
class DmaRequestWrapper : public Portal {
public:
    DmaRequestWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = DmaRequest_handleMessage, int bufsize = DmaRequest_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&DmaRequest_cbTable, this, poller) {
    };
    DmaRequestWrapper(int id, PortalTransportFunctions *item, void *param, PORTAL_INDFUNC cba = DmaRequest_handleMessage, int bufsize = DmaRequest_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&DmaRequest_cbTable, item, param, this, poller) {
    };
    DmaRequestWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, DmaRequest_reqinfo, DmaRequest_handleMessage, (void *)&DmaRequest_cbTable, this, poller) {
    };
    DmaRequestWrapper(int id, PortalTransportFunctions *item, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, DmaRequest_reqinfo, DmaRequest_handleMessage, (void *)&DmaRequest_cbTable, item, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("DmaRequestWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void burstLen ( const uint16_t burstLenBytes ) = 0;
    virtual void transferToFpga ( const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag ) = 0;
    virtual void transferFromFpga ( const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag ) = 0;
};
#endif // _DMAREQUEST_H_
