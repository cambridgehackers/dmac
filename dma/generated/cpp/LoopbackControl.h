#include "GeneratedTypes.h"
#ifndef _LOOPBACKCONTROL_H_
#define _LOOPBACKCONTROL_H_
#include "portal.h"

class LoopbackControlProxy : public Portal {
    LoopbackControlCb *cb;
public:
    LoopbackControlProxy(int id, int tile = DEFAULT_TILE, LoopbackControlCb *cbarg = &LoopbackControlProxyReq, int bufsize = LoopbackControl_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    LoopbackControlProxy(int id, PortalTransportFunctions *item, void *param, LoopbackControlCb *cbarg = &LoopbackControlProxyReq, int bufsize = LoopbackControl_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, item, param, this, poller), cb(cbarg) {};
    LoopbackControlProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, LoopbackControl_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&LoopbackControlProxyReq) {};
    int loopback ( const int lb ) { return cb->loopback (&pint, lb); };
    int marker ( const uint32_t fb ) { return cb->marker (&pint, fb); };
};

extern LoopbackControlCb LoopbackControl_cbTable;
class LoopbackControlWrapper : public Portal {
public:
    LoopbackControlWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = LoopbackControl_handleMessage, int bufsize = LoopbackControl_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&LoopbackControl_cbTable, this, poller) {
    };
    LoopbackControlWrapper(int id, PortalTransportFunctions *item, void *param, PORTAL_INDFUNC cba = LoopbackControl_handleMessage, int bufsize = LoopbackControl_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&LoopbackControl_cbTable, item, param, this, poller) {
    };
    LoopbackControlWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, LoopbackControl_reqinfo, LoopbackControl_handleMessage, (void *)&LoopbackControl_cbTable, this, poller) {
    };
    LoopbackControlWrapper(int id, PortalTransportFunctions *item, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, LoopbackControl_reqinfo, LoopbackControl_handleMessage, (void *)&LoopbackControl_cbTable, item, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("LoopbackControlWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void loopback ( const int lb ) = 0;
    virtual void marker ( const uint32_t fb ) = 0;
};
#endif // _LOOPBACKCONTROL_H_
