#include "GeneratedTypes.h"

static ConnectalMethodJsonInfo DmaIndicationInfo[] = {
    {"transferToFpgaDone", ((ConnectalParamJsonInfo[]){
        {"objId", Connectaloffsetof(DmaIndication_transferToFpgaDoneData,objId), ITYPE_uint32_t},
        {"base", Connectaloffsetof(DmaIndication_transferToFpgaDoneData,base), ITYPE_uint32_t},
        {"tag", Connectaloffsetof(DmaIndication_transferToFpgaDoneData,tag), ITYPE_other},
        {"cycles", Connectaloffsetof(DmaIndication_transferToFpgaDoneData,cycles), ITYPE_uint32_t},
        {NULL, CHAN_NUM_DmaIndication_transferToFpgaDone}}) },
    {"transferFromFpgaDone", ((ConnectalParamJsonInfo[]){
        {"objId", Connectaloffsetof(DmaIndication_transferFromFpgaDoneData,objId), ITYPE_uint32_t},
        {"base", Connectaloffsetof(DmaIndication_transferFromFpgaDoneData,base), ITYPE_uint32_t},
        {"tag", Connectaloffsetof(DmaIndication_transferFromFpgaDoneData,tag), ITYPE_other},
        {"cycles", Connectaloffsetof(DmaIndication_transferFromFpgaDoneData,cycles), ITYPE_uint32_t},
        {NULL, CHAN_NUM_DmaIndication_transferFromFpgaDone}}) },{}};

int DmaIndicationJson_transferToFpgaDone ( struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles )
{
    DmaIndication_transferToFpgaDoneData tempdata;
    tempdata.objId = objId;
    tempdata.base = base;
    memcpy(&tempdata.tag, &tag, sizeof(tempdata.tag));
    tempdata.cycles = cycles;
    connectalJsonEncode(p, &tempdata, &DmaIndicationInfo[CHAN_NUM_DmaIndication_transferToFpgaDone]);
    return 0;
};

int DmaIndicationJson_transferFromFpgaDone ( struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles )
{
    DmaIndication_transferFromFpgaDoneData tempdata;
    tempdata.objId = objId;
    tempdata.base = base;
    memcpy(&tempdata.tag, &tag, sizeof(tempdata.tag));
    tempdata.cycles = cycles;
    connectalJsonEncode(p, &tempdata, &DmaIndicationInfo[CHAN_NUM_DmaIndication_transferFromFpgaDone]);
    return 0;
};

DmaIndicationCb DmaIndicationJsonProxyReq = {
    portal_disconnect,
    DmaIndicationJson_transferToFpgaDone,
    DmaIndicationJson_transferFromFpgaDone,
};
int DmaIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    DmaIndicationData tempdata __attribute__ ((unused));
    channel = connnectalJsonDecode(p, channel, &tempdata, DmaIndicationInfo);
    switch (channel) {
    case CHAN_NUM_DmaIndication_transferToFpgaDone: {
        ((DmaIndicationCb *)p->cb)->transferToFpgaDone(p, tempdata.transferToFpgaDone.objId, tempdata.transferToFpgaDone.base, tempdata.transferToFpgaDone.tag, tempdata.transferToFpgaDone.cycles);
      } break;
    case CHAN_NUM_DmaIndication_transferFromFpgaDone: {
        ((DmaIndicationCb *)p->cb)->transferFromFpgaDone(p, tempdata.transferFromFpgaDone.objId, tempdata.transferFromFpgaDone.base, tempdata.transferFromFpgaDone.tag, tempdata.transferFromFpgaDone.cycles);
      } break;
    default:
        PORTAL_PRINTF("DmaIndicationJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("DmaIndicationJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
