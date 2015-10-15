
## default location of connectal
CONNECTALDIR?=/usr/share/connectal

## refer to the files in this directory via $(DMADIR)/ because this Makefile is included in ../dma128/Makefile
SRCDIR=../src/

# S2H_INTERFACES = DmaRequest:DmaTop.request0,request1
# H2S_INTERFACES = DmaTop:DmaIndication,DmaIndication
# MEM_READ_INTERFACES = lDmaTop.readClient
# MEM_WRITE_INTERFACES = lDmaTop.writeClient
# BSVFILES = $(SRCDIR)/DmaController.bsv
# CPPFILES= ../src/dmac.cpp
# PIN_TYPE=DmaTopPins
# PIN_TYPE_INCLUDE=DmaTopPins

# include $(CONNECTALDIR)/Makefile.connectal

# BURST_LEN_SIZE=10

# CONNECTALFLAGS += -D USE_DUAL_CLOCK_FIFOF --shared

all: connectal ipcore

connectal:
	mkdir -p connectal/cpp connectal/bsv connectal/drivers/portalmem connectal/drivers/pcieportal connectal/verilog connectal/constraints
	cp $(CONNECTALDIR)/bsv/*.bsv connectal/bsv
	cp $(CONNECTALDIR)/lib/bsv/*.bsv connectal/bsv
	cp $(CONNECTALDIR)/generated/xilinx/*.bsv connectal/bsv
	cp $(CONNECTALDIR)/cpp/* connectal/cpp
	cp $(CONNECTALDIR)/drivers/portalmem/*.h connectal/drivers/portalmem
	cp $(CONNECTALDIR)/drivers/pcieportal/*.h connectal/drivers/pcieportal
	cp $(CONNECTALDIR)/verilog/*.v connectal/verilog
	cp $(CONNECTALDIR)/constraints/xilinx/*.xdc connectal/constraints

ipcore:
	vivado -mode batch -source pciecore.tcl
