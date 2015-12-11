#include "GeneratedTypes.h"

static ConnectalMethodJsonInfo DmaRequestInfo[] = {
    {"writeRequestSize", ((ConnectalParamJsonInfo[]){
        {"burstLenBytes", Connectaloffsetof(DmaRequest_writeRequestSizeData,burstLenBytes), ITYPE_uint16_t},
        {NULL, CHAN_NUM_DmaRequest_writeRequestSize}}) },
    {"readRequestSize", ((ConnectalParamJsonInfo[]){
        {"readRequestBytes", Connectaloffsetof(DmaRequest_readRequestSizeData,readRequestBytes), ITYPE_uint16_t},
        {NULL, CHAN_NUM_DmaRequest_readRequestSize}}) },
    {"transferToFpga", ((ConnectalParamJsonInfo[]){
        {"objId", Connectaloffsetof(DmaRequest_transferToFpgaData,objId), ITYPE_uint32_t},
        {"base", Connectaloffsetof(DmaRequest_transferToFpgaData,base), ITYPE_uint32_t},
        {"bytes", Connectaloffsetof(DmaRequest_transferToFpgaData,bytes), ITYPE_uint32_t},
        {"tag", Connectaloffsetof(DmaRequest_transferToFpgaData,tag), ITYPE_other},
        {NULL, CHAN_NUM_DmaRequest_transferToFpga}}) },
    {"transferFromFpga", ((ConnectalParamJsonInfo[]){
        {"objId", Connectaloffsetof(DmaRequest_transferFromFpgaData,objId), ITYPE_uint32_t},
        {"base", Connectaloffsetof(DmaRequest_transferFromFpgaData,base), ITYPE_uint32_t},
        {"bytes", Connectaloffsetof(DmaRequest_transferFromFpgaData,bytes), ITYPE_uint32_t},
        {"tag", Connectaloffsetof(DmaRequest_transferFromFpgaData,tag), ITYPE_other},
        {NULL, CHAN_NUM_DmaRequest_transferFromFpga}}) },{}};

int DmaRequestJson_writeRequestSize ( struct PortalInternal *p, const uint16_t burstLenBytes )
{
    DmaRequest_writeRequestSizeData tempdata;
    tempdata.burstLenBytes = burstLenBytes;
    connectalJsonEncode(p, &tempdata, &DmaRequestInfo[CHAN_NUM_DmaRequest_writeRequestSize]);
    return 0;
};

int DmaRequestJson_readRequestSize ( struct PortalInternal *p, const uint16_t readRequestBytes )
{
    DmaRequest_readRequestSizeData tempdata;
    tempdata.readRequestBytes = readRequestBytes;
    connectalJsonEncode(p, &tempdata, &DmaRequestInfo[CHAN_NUM_DmaRequest_readRequestSize]);
    return 0;
};

int DmaRequestJson_transferToFpga ( struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag )
{
    DmaRequest_transferToFpgaData tempdata;
    tempdata.objId = objId;
    tempdata.base = base;
    tempdata.bytes = bytes;
    memcpy(&tempdata.tag, &tag, sizeof(tempdata.tag));
    connectalJsonEncode(p, &tempdata, &DmaRequestInfo[CHAN_NUM_DmaRequest_transferToFpga]);
    return 0;
};

int DmaRequestJson_transferFromFpga ( struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag )
{
    DmaRequest_transferFromFpgaData tempdata;
    tempdata.objId = objId;
    tempdata.base = base;
    tempdata.bytes = bytes;
    memcpy(&tempdata.tag, &tag, sizeof(tempdata.tag));
    connectalJsonEncode(p, &tempdata, &DmaRequestInfo[CHAN_NUM_DmaRequest_transferFromFpga]);
    return 0;
};

DmaRequestCb DmaRequestJsonProxyReq = {
    portal_disconnect,
    DmaRequestJson_writeRequestSize,
    DmaRequestJson_readRequestSize,
    DmaRequestJson_transferToFpga,
    DmaRequestJson_transferFromFpga,
};
int DmaRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    DmaRequestData tempdata __attribute__ ((unused));
    channel = connnectalJsonDecode(p, channel, &tempdata, DmaRequestInfo);
    switch (channel) {
    case CHAN_NUM_DmaRequest_writeRequestSize: {
        ((DmaRequestCb *)p->cb)->writeRequestSize(p, tempdata.writeRequestSize.burstLenBytes);
      } break;
    case CHAN_NUM_DmaRequest_readRequestSize: {
        ((DmaRequestCb *)p->cb)->readRequestSize(p, tempdata.readRequestSize.readRequestBytes);
      } break;
    case CHAN_NUM_DmaRequest_transferToFpga: {
        ((DmaRequestCb *)p->cb)->transferToFpga(p, tempdata.transferToFpga.objId, tempdata.transferToFpga.base, tempdata.transferToFpga.bytes, tempdata.transferToFpga.tag);
      } break;
    case CHAN_NUM_DmaRequest_transferFromFpga: {
        ((DmaRequestCb *)p->cb)->transferFromFpga(p, tempdata.transferFromFpga.objId, tempdata.transferFromFpga.base, tempdata.transferFromFpga.bytes, tempdata.transferFromFpga.tag);
      } break;
    default:
        PORTAL_PRINTF("DmaRequestJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("DmaRequestJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
