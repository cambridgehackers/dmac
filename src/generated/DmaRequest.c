#include "GeneratedTypes.h"

int DmaRequest_writeRequestSize ( struct PortalInternal *p, const uint16_t burstLenBytes )
{
    volatile unsigned int* temp_working_addr_start = p->item->mapchannelReq(p, CHAN_NUM_DmaRequest_writeRequestSize, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->item->busywait(p, CHAN_NUM_DmaRequest_writeRequestSize, "DmaRequest_writeRequestSize")) return 1;
    p->item->write(p, &temp_working_addr, burstLenBytes);
    p->item->send(p, temp_working_addr_start, (CHAN_NUM_DmaRequest_writeRequestSize << 16) | 2, -1);
    return 0;
};

int DmaRequest_readRequestSize ( struct PortalInternal *p, const uint16_t readRequestBytes )
{
    volatile unsigned int* temp_working_addr_start = p->item->mapchannelReq(p, CHAN_NUM_DmaRequest_readRequestSize, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->item->busywait(p, CHAN_NUM_DmaRequest_readRequestSize, "DmaRequest_readRequestSize")) return 1;
    p->item->write(p, &temp_working_addr, readRequestBytes);
    p->item->send(p, temp_working_addr_start, (CHAN_NUM_DmaRequest_readRequestSize << 16) | 2, -1);
    return 0;
};

int DmaRequest_transferToFpga ( struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag )
{
    volatile unsigned int* temp_working_addr_start = p->item->mapchannelReq(p, CHAN_NUM_DmaRequest_transferToFpga, 5);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->item->busywait(p, CHAN_NUM_DmaRequest_transferToFpga, "DmaRequest_transferToFpga")) return 1;
    p->item->write(p, &temp_working_addr, (objId>>24));
    p->item->write(p, &temp_working_addr, (base>>24)|(((unsigned long)objId)<<8));
    p->item->write(p, &temp_working_addr, (bytes>>24)|(((unsigned long)base)<<8));
    p->item->write(p, &temp_working_addr, tag|(((unsigned long)bytes)<<8));
    p->item->send(p, temp_working_addr_start, (CHAN_NUM_DmaRequest_transferToFpga << 16) | 5, -1);
    return 0;
};

int DmaRequest_transferFromFpga ( struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag )
{
    volatile unsigned int* temp_working_addr_start = p->item->mapchannelReq(p, CHAN_NUM_DmaRequest_transferFromFpga, 5);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->item->busywait(p, CHAN_NUM_DmaRequest_transferFromFpga, "DmaRequest_transferFromFpga")) return 1;
    p->item->write(p, &temp_working_addr, (objId>>24));
    p->item->write(p, &temp_working_addr, (base>>24)|(((unsigned long)objId)<<8));
    p->item->write(p, &temp_working_addr, (bytes>>24)|(((unsigned long)base)<<8));
    p->item->write(p, &temp_working_addr, tag|(((unsigned long)bytes)<<8));
    p->item->send(p, temp_working_addr_start, (CHAN_NUM_DmaRequest_transferFromFpga << 16) | 5, -1);
    return 0;
};

DmaRequestCb DmaRequestProxyReq = {
    portal_disconnect,
    DmaRequest_writeRequestSize,
    DmaRequest_readRequestSize,
    DmaRequest_transferToFpga,
    DmaRequest_transferFromFpga,
};
int DmaRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    DmaRequestData tempdata __attribute__ ((unused));
    volatile unsigned int* temp_working_addr = p->item->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_DmaRequest_writeRequestSize: {
        
        p->item->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.writeRequestSize.burstLenBytes = (uint16_t)(((tmp)&0xfffful));((DmaRequestCb *)p->cb)->writeRequestSize(p, tempdata.writeRequestSize.burstLenBytes);
      } break;
    case CHAN_NUM_DmaRequest_readRequestSize: {
        
        p->item->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.readRequestSize.readRequestBytes = (uint16_t)(((tmp)&0xfffful));((DmaRequestCb *)p->cb)->readRequestSize(p, tempdata.readRequestSize.readRequestBytes);
      } break;
    case CHAN_NUM_DmaRequest_transferToFpga: {
        
        p->item->recv(p, temp_working_addr, 4, &tmpfd);
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferToFpga.objId = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferToFpga.base = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tempdata.transferToFpga.objId |= (uint32_t)(((tmp>>8)&0xfffffful));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferToFpga.bytes = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tempdata.transferToFpga.base |= (uint32_t)(((tmp>>8)&0xfffffful));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferToFpga.tag = (uint8_t)(((tmp)&0xfful));
        tempdata.transferToFpga.bytes |= (uint32_t)(((tmp>>8)&0xfffffful));((DmaRequestCb *)p->cb)->transferToFpga(p, tempdata.transferToFpga.objId, tempdata.transferToFpga.base, tempdata.transferToFpga.bytes, tempdata.transferToFpga.tag);
      } break;
    case CHAN_NUM_DmaRequest_transferFromFpga: {
        
        p->item->recv(p, temp_working_addr, 4, &tmpfd);
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferFromFpga.objId = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferFromFpga.base = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tempdata.transferFromFpga.objId |= (uint32_t)(((tmp>>8)&0xfffffful));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferFromFpga.bytes = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tempdata.transferFromFpga.base |= (uint32_t)(((tmp>>8)&0xfffffful));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferFromFpga.tag = (uint8_t)(((tmp)&0xfful));
        tempdata.transferFromFpga.bytes |= (uint32_t)(((tmp>>8)&0xfffffful));((DmaRequestCb *)p->cb)->transferFromFpga(p, tempdata.transferFromFpga.objId, tempdata.transferFromFpga.base, tempdata.transferFromFpga.bytes, tempdata.transferFromFpga.tag);
      } break;
    default:
        PORTAL_PRINTF("DmaRequest_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("DmaRequest_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
