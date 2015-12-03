#include "GeneratedTypes.h"

int DmaIndication_transferToFpgaDone ( struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles )
{
    volatile unsigned int* temp_working_addr_start = p->item->mapchannelReq(p, CHAN_NUM_DmaIndication_transferToFpgaDone, 5);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->item->busywait(p, CHAN_NUM_DmaIndication_transferToFpgaDone, "DmaIndication_transferToFpgaDone")) return 1;
    p->item->write(p, &temp_working_addr, (objId>>24));
    p->item->write(p, &temp_working_addr, (base>>24)|(((unsigned long)objId)<<8));
    p->item->write(p, &temp_working_addr, tag|(((unsigned long)base)<<8));
    p->item->write(p, &temp_working_addr, cycles);
    p->item->send(p, temp_working_addr_start, (CHAN_NUM_DmaIndication_transferToFpgaDone << 16) | 5, -1);
    return 0;
};

int DmaIndication_transferFromFpgaDone ( struct PortalInternal *p, const uint32_t objId, const uint32_t base, const uint8_t tag, const uint32_t cycles )
{
    volatile unsigned int* temp_working_addr_start = p->item->mapchannelReq(p, CHAN_NUM_DmaIndication_transferFromFpgaDone, 5);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->item->busywait(p, CHAN_NUM_DmaIndication_transferFromFpgaDone, "DmaIndication_transferFromFpgaDone")) return 1;
    p->item->write(p, &temp_working_addr, (objId>>24));
    p->item->write(p, &temp_working_addr, (base>>24)|(((unsigned long)objId)<<8));
    p->item->write(p, &temp_working_addr, tag|(((unsigned long)base)<<8));
    p->item->write(p, &temp_working_addr, cycles);
    p->item->send(p, temp_working_addr_start, (CHAN_NUM_DmaIndication_transferFromFpgaDone << 16) | 5, -1);
    return 0;
};

DmaIndicationCb DmaIndicationProxyReq = {
    portal_disconnect,
    DmaIndication_transferToFpgaDone,
    DmaIndication_transferFromFpgaDone,
};
int DmaIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    DmaIndicationData tempdata __attribute__ ((unused));
    volatile unsigned int* temp_working_addr = p->item->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_DmaIndication_transferToFpgaDone: {
        
        p->item->recv(p, temp_working_addr, 4, &tmpfd);
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferToFpgaDone.objId = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferToFpgaDone.base = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tempdata.transferToFpgaDone.objId |= (uint32_t)(((tmp>>8)&0xfffffful));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferToFpgaDone.tag = (uint8_t)(((tmp)&0xfful));
        tempdata.transferToFpgaDone.base |= (uint32_t)(((tmp>>8)&0xfffffful));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferToFpgaDone.cycles = (uint32_t)(((tmp)&0xfffffffful));((DmaIndicationCb *)p->cb)->transferToFpgaDone(p, tempdata.transferToFpgaDone.objId, tempdata.transferToFpgaDone.base, tempdata.transferToFpgaDone.tag, tempdata.transferToFpgaDone.cycles);
      } break;
    case CHAN_NUM_DmaIndication_transferFromFpgaDone: {
        
        p->item->recv(p, temp_working_addr, 4, &tmpfd);
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferFromFpgaDone.objId = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferFromFpgaDone.base = (uint32_t)(((uint32_t)(((tmp)&0xfful))<<24));
        tempdata.transferFromFpgaDone.objId |= (uint32_t)(((tmp>>8)&0xfffffful));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferFromFpgaDone.tag = (uint8_t)(((tmp)&0xfful));
        tempdata.transferFromFpgaDone.base |= (uint32_t)(((tmp>>8)&0xfffffful));
        tmp = p->item->read(p, &temp_working_addr);
        tempdata.transferFromFpgaDone.cycles = (uint32_t)(((tmp)&0xfffffffful));((DmaIndicationCb *)p->cb)->transferFromFpgaDone(p, tempdata.transferFromFpgaDone.objId, tempdata.transferFromFpgaDone.base, tempdata.transferFromFpgaDone.tag, tempdata.transferFromFpgaDone.cycles);
      } break;
    default:
        PORTAL_PRINTF("DmaIndication_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("DmaIndication_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
