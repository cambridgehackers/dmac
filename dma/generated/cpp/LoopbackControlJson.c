#include "GeneratedTypes.h"

static ConnectalMethodJsonInfo LoopbackControlInfo[] = {
    {"loopback", ((ConnectalParamJsonInfo[]){
        {"lb", Connectaloffsetof(LoopbackControl_loopbackData,lb), ITYPE_other},
        {NULL, CHAN_NUM_LoopbackControl_loopback}}) },
    {"marker", ((ConnectalParamJsonInfo[]){
        {"fb", Connectaloffsetof(LoopbackControl_markerData,fb), ITYPE_uint32_t},
        {NULL, CHAN_NUM_LoopbackControl_marker}}) },{}};

int LoopbackControlJson_loopback ( struct PortalInternal *p, const int lb )
{
    LoopbackControl_loopbackData tempdata;
    memcpy(&tempdata.lb, &lb, sizeof(tempdata.lb));
    connectalJsonEncode(p, &tempdata, &LoopbackControlInfo[CHAN_NUM_LoopbackControl_loopback]);
    return 0;
};

int LoopbackControlJson_marker ( struct PortalInternal *p, const uint32_t fb )
{
    LoopbackControl_markerData tempdata;
    tempdata.fb = fb;
    connectalJsonEncode(p, &tempdata, &LoopbackControlInfo[CHAN_NUM_LoopbackControl_marker]);
    return 0;
};

LoopbackControlCb LoopbackControlJsonProxyReq = {
    portal_disconnect,
    LoopbackControlJson_loopback,
    LoopbackControlJson_marker,
};
int LoopbackControlJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    LoopbackControlData tempdata __attribute__ ((unused));
    channel = connnectalJsonDecode(p, channel, &tempdata, LoopbackControlInfo);
    switch (channel) {
    case CHAN_NUM_LoopbackControl_loopback: {
        ((LoopbackControlCb *)p->cb)->loopback(p, tempdata.loopback.lb);
      } break;
    case CHAN_NUM_LoopbackControl_marker: {
        ((LoopbackControlCb *)p->cb)->marker(p, tempdata.marker.fb);
      } break;
    default:
        PORTAL_PRINTF("LoopbackControlJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("LoopbackControlJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
