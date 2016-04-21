
DTOP=.
BOARD?=vc709
PREFIX?=/usr/local
DMAC_DIR?=../src

BSCFLAGS_COMMON = $(BSV_FLAGS_DMAC) -D BOARD_$(BOARD)
BSCFLAGS_COMMON += +RTS -K46777216 -RTS -show-schedule
BSCPATHFLAGS=  -bdir $(DTOP)/obj-$(BOARD) -vdir $(DTOP)/verilog -simdir $(DTOP)/obj-$(BOARD) -info-dir $(DTOP)/obj-$(BOARD)
BSCFLAGS_COMMON += $(BSCWARNFLAGS) $(BSCOPTFLAGS) $(BSCPATHFLAGS) --wait-for-license
ifeq ($(BOARD),kc705)
PCIE2=1
endif
ifeq ($(BOARD),kc705g2)
PCIE2=1
endif
ifeq ($(BOARD),vc707)
PCIE2=1
endif
ifeq ($(BOARD),vc707g2)
PCIE2=1
endif
ifeq ($(BOARD),vc709)
PCIE3=1
endif
ifeq ($(PCIE3),1)
BSCFLAGS_COMMON += -D DataBusWidth=256 -D TRACE_PORTAL
else
BSCFLAGS_COMMON += -D DataBusWidth=128
endif

all: testdma-$(BOARD) bits

clean:
	rm -fr *.so bsim testdma-bluesim testdma-$(BOARD) obj verilog $(BOARD) vivado.* *.o

ConnectalProjectConfig.bsv: 
	if [ -f $(DMAC_DIR)/template/ConnectalProjectConfig.bsv ] ; then cp -v $(DMAC_DIR)/template/ConnectalProjectConfig.bsv .; fi

ifneq ($(BOARD),bluesim)
bits: mkExample.bit

run: testdma-$(BOARD) mkExample.bit
	fpgajtag mkExample.bit
	LD_LIBRARY_PATH=$(PREFIX)/lib NOPROGRAM=1 ./testdma-$(BOARD)

mkExample.bit: verilog/mkExample.v ipcore
	rm -fr $(BOARD)
	DMAC_DIR=$(DMAC_DIR) vivado -mode batch -source impl.tcl
	cp -v $(BOARD)/$(BOARD).runs/impl_1/mkExample.bit mkExample.bit

verilog/mkExample.v: Example.bsv ConnectalProjectConfig.bsv
	mkdir -p obj-$(BOARD) verilog
	bsc $(BSCFLAGS_COMMON) -u -g mkExample Example.bsv
	$(Q)sed -i 's|// On .*|// timestamp removed|' verilog/*.v
	$(Q)sed -i 's|  wire.*PROBE[,;]|(* mark_debug="true" *)&|' verilog/*.v 
	$(Q)sed -i 's|  wire.*PROBE_VALID[,;]|(* mark_debug="true" *)&|' verilog/*.v 
else
bits: bsim

run: testdma-$(BOARD) bsim
	PATH=.:$(PATH) LD_LIBRARY_PATH=.:../src catchsegv ./testdma-bluesim

obj-$(BOARD)/mkExample.ba: Example.bsv ConnectalProjectConfig.bsv
	mkdir -p obj-$(BOARD) verilog
	bsc $(BSCFLAGS_COMMON) -sim -u -g mkExample Example.bsv

bsim: obj-$(BOARD)/mkExample.ba
	bsc $(BSCFLAGS_COMMON) -sim -u -e mkExample -o bsim -L $(DMAC_DIR) -l dmac-bluesim obj-$(BOARD)/mkExample.ba 

endif

testdma.o: testdma.cpp
	g++ -O -g -I../src -c testdma.cpp


.PHONY: $(DMAC_DIR)/libdmac-$(BOARD).a

$(DMAC_DIR)/libdmac-$(BOARD).a:
	make -C ../src BOARD=$BOARD libdmac-$(BOARD).a

testdma-$(BOARD): testdma.o $(DMAC_DIR)/libdmac-$(BOARD).a
	g++ -O -g -o testdma-$(BOARD) testdma.o -L$(DMAC_DIR) -ldmac-$(BOARD) -lpthread

include $(DMAC_DIR)/Makefile.dmac
