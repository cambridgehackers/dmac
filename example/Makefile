
DTOP=.
BOARD=vc709
PREFIX?=/usr/local

BSCFLAGS_COMMON = $(BSV_FLAGS_DMAC)
BSCFLAGS_COMMON += +RTS -K46777216 -RTS -show-schedule
BSCPATHFLAGS=  -bdir $(DTOP)/obj -vdir $(DTOP)/verilog -simdir $(DTOP)/obj -info-dir $(DTOP)/obj 
BSCFLAGS_COMMON += $(BSCWARNFLAGS) $(BSCOPTFLAGS) $(BSCPATHFLAGS) --wait-for-license

all: testdma-$(BOARD) mkExample.bit

run: testdma-$(BOARD) mkExample.bit
	fpgajtag mkExample.bit
	LD_LIBRARY_PATH=$(PREFIX)/lib ./testdma-$(BOARD)

mkExample.bit: verilog/mkExample.v ipcore
	rm -fr vc709
	vivado -mode batch -source impl.tcl
	cp -v vc709/vc709.runs/impl_1/mkExample.bit mkExample.bit

verilog/mkExample.v: Example.bsv
	mkdir -p obj verilog
	bsc $(BSCFLAGS_COMMON) -u -verilog -g mkExample Example.bsv

testdmacopy.o: testdmacopy.cpp
	g++ -O -I$(DESTDIR)$(PREFIX)/include/dmac -c testdmacopy.cpp


testdma-$(BOARD): testdmacopy.o
	g++ -O -o testdma-$(BOARD) testdmacopy.o -L$(DESTDIR)$(PREFIX)/lib -ldmac-$(BOARD) -lpthread

include $(DESTDIR)$(PREFIX)/share/dmac/Makefile.dmac
