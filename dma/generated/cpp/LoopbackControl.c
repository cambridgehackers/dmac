#include "GeneratedTypes.h"

int LoopbackControl_loopback ( struct PortalInternal *p, const int lb )
{
    volatile unsigned int* temp_working_addr_start = p->item->mapchannelReq(p, CHAN_NUM_LoopbackControl_loopback, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->item->busywait(p, CHAN_NUM_LoopbackControl_loopback, "LoopbackControl_loopback")) return 1;
    p->item->write(p, &temp_working_addr, (lb & 1L));
    p->item->send(p, temp_working_addr_start, (CHAN_NUM_LoopbackControl_loopback << 16) | 2, -1);
    return 0;
};

int LoopbackControl_marker ( struct PortalInternal *p, const uint32_t fb )
{
    volatile unsigned int* temp_working_addr_start = p->item->mapchannelReq(p, CHAN_NUM_LoopbackControl_marker, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->item->busywait(p, CHAN_NUM_LoopbackControl_marker, "LoopbackControl_marker")) return 1;
    p->item->write(p, &temp_working_addr, fb);
    p->item->send(p, temp_working_addr_start, (CHAN_NUM_LoopbackControl_marker << 16) | 2, -1);
    return 0;
};

LoopbackControlCb LoopbackControlProxyReq = {
    portal_disconnect,
    LoopbackControl_loopback,
    LoopbackControl_marker,
};
int LoopbackControl_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    LoopbackControlData tempdata __attribute__ ((unused));
    volatile unsigned int* temp_working_addr = p->item->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_LoopbackControl_loopback: {
        
        p->item->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.loopback.lb = (int)(((tmp)&0x1ul));((LoopbackControlCb *)p->cb)->loopback(p, tempdata.loopback.lb);
      } break;
    case CHAN_NUM_LoopbackControl_marker: {
        
        p->item->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.marker.fb = (uint32_t)(((tmp)&0xfffffffful));((LoopbackControlCb *)p->cb)->marker(p, tempdata.marker.fb);
      } break;
    default:
        PORTAL_PRINTF("LoopbackControl_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("LoopbackControl_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
