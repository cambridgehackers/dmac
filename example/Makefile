
DTOP=.
BOARD=vc709
PREFIX?=/usr/local
DMAC_DIR?=../src

BSCFLAGS_COMMON = $(BSV_FLAGS_DMAC) -D BOARD_$(BOARD)
BSCFLAGS_COMMON += +RTS -K46777216 -RTS -show-schedule
BSCPATHFLAGS=  -bdir $(DTOP)/obj-$(BOARD) -vdir $(DTOP)/verilog -simdir $(DTOP)/obj-$(BOARD) -info-dir $(DTOP)/obj-$(BOARD)
BSCFLAGS_COMMON += $(BSCWARNFLAGS) $(BSCOPTFLAGS) $(BSCPATHFLAGS) --wait-for-license

all: testdma-$(BOARD) bits

clean:
	rm -fr *.so bsim testdma-bluesim testdma-vc709 obj verilog vc709 vivado.* *.o

ConnectalProjectConfig.bsv: 
	if [ -f $(DMAC_DIR)/template/ConnectalProjectConfig.bsv ] ; then cp -v $(DMAC_DIR)/template/ConnectalProjectConfig.bsv .; fi

ifneq ($(BOARD),bluesim)
bits: mkExample.bit

run: testdma-$(BOARD) mkExample.bit
	fpgajtag mkExample.bit
	LD_LIBRARY_PATH=$(PREFIX)/lib NOPROGRAM=1 ./testdma-$(BOARD)

mkExample.bit: verilog/mkExample.v ipcore
	rm -fr vc709
	DMAC_DIR=$(DMAC_DIR) vivado -mode batch -source impl.tcl
	cp -v vc709/vc709.runs/impl_1/mkExample.bit mkExample.bit

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

testdmacopy.o: testdmacopy.cpp
	g++ -O -I../src -c testdmacopy.cpp


testdma-$(BOARD): testdmacopy.o $(DMAC_DIR)/libdmac-$(BOARD).a
	g++ -O -o testdma-$(BOARD) testdmacopy.o -L$(DMAC_DIR) -ldmac-$(BOARD) -lpthread

include $(DMAC_DIR)/Makefile.dmac
