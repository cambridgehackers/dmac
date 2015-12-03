#include "GeneratedTypes.h"
#ifndef _DMAINDICATION_H_
#define _DMAINDICATION_H_
#include "portal.h"

class DmaIndicationProxy : public Portal {
    DmaIndicationCb *cb;
public:
    DmaIndicationProxy(int id, int tile = DEFAULT_TILE, DmaIndicationCb *cbarg = &DmaIndicationProxyReq, int bufsize = DmaIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    DmaIndicationProxy(int id, PortalTransportFunctions *item, void *param, DmaIndicationCb *cbarg = &DmaIndicationProxyReq, int bufsize = DmaIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, item, param, this, poller), cb(cbarg) {};
    DmaIndicationProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, DmaIndication_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&DmaIndicationProxyReq) {};
    int transferToFpgaDone ( const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles ) { return cb->transferToFpgaDone (&pint, objId, base, tag, cycles); };
    int transferFromFpgaDone ( const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles ) { return cb->transferFromFpgaDone (&pint, objId, base, tag, cycles); };
};

extern DmaIndicationCb DmaIndication_cbTable;
class DmaIndicationWrapper : public Portal {
public:
    DmaIndicationWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = DmaIndication_handleMessage, int bufsize = DmaIndication_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&DmaIndication_cbTable, this, poller) {
    };
    DmaIndicationWrapper(int id, PortalTransportFunctions *item, void *param, PORTAL_INDFUNC cba = DmaIndication_handleMessage, int bufsize = DmaIndication_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&DmaIndication_cbTable, item, param, this, poller) {
    };
    DmaIndicationWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, DmaIndication_reqinfo, DmaIndication_handleMessage, (void *)&DmaIndication_cbTable, this, poller) {
    };
    DmaIndicationWrapper(int id, PortalTransportFunctions *item, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, DmaIndication_reqinfo, DmaIndication_handleMessage, (void *)&DmaIndication_cbTable, item, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("DmaIndicationWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void transferToFpgaDone ( const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles ) = 0;
    virtual void transferFromFpgaDone ( const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles ) = 0;
};
#endif // _DMAINDICATION_H_
