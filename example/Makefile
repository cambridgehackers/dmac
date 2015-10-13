
DTOP=.
BOARD=vc709

BSCWARNFLAGS += -demote-errors G0066:G0045 -suppress-warnings G0046:G0020:S0015:S0080:S0039:T0127

BSCFLAGS_COMMON += +RTS -K46777216 -RTS
BSCOPTFLAGS= -show-schedule -aggressive-conditions
BSCPATHFLAGS=  -bdir $(DTOP)/obj -vdir $(DTOP)/verilog -simdir $(DTOP)/obj -info-dir $(DTOP)/obj -p +:../src:../src/top:../src/connectal/bsv:../src/generated
BSCFLAGS_COMMON += $(BSCWARNFLAGS) $(BSCOPTFLAGS) $(BSCPATHFLAGS) --wait-for-license
BSCFLAGS_COMMON += -D ClockDefaultParam

all: testdma-$(BOARD) mkExample.bit

run: testdma-$(BOARD) mkExample.bit
	fpgajtag mkExample.bit
	LD_LIBRARY_PATH=. ./testdma-$(BOARD)

mkExample.bit: verilog/mkExample.v
	rm -fr vc709
	vivado -mode batch -source impl.tcl
	cp -v vc709/vc709.runs/impl_1/mkExample.bit mkExample.bit

verilog/mkExample.v: Example.bsv
	mkdir -p obj verilog
	bsc $(BSCFLAGS_COMMON) -u -verilog -g mkExample Example.bsv

testdmacopy.o: testdmacopy.cpp
	g++ -O -I../src -c testdmacopy.cpp

PORTAL_INFRA := portal.c transportHardware.c transportSocket.c portalJson.c portalPrintf.c poller.cpp sock_utils.c timer.c dmaManager.c platformMemory.cpp
GENERATED_CPP=GeneratedCppCallbacks.cpp MemServerRequest.c MemServerRequestJson.c MMURequest.c MMURequestJson.c MemServerIndication.c MemServerIndicationJson.c MMUIndication.c MMUIndicationJson.c DmaRequest.c DmaRequestJson.c DmaIndication.c DmaIndicationJson.c
PORTAL_SRC_FILES := $(addprefix ../src/connectal/cpp/, $(PORTAL_INFRA)) \
                    $(addprefix ../src/generated/, $(GENERATED_CPP))
SOURCES = ../src/dmac.cpp $(PORTAL_SRC_FILES)

CFLAGS = -I../src -I../src/connectal/cpp -I../src/generated -I../src/connectal -D$(BOARD)

libdmac-$(BOARD).so:
	$(Q)g++ -shared -fpic $(CFLAGS) -o libdmac-$(BOARD).so  $(SOURCES) $(LDLIBS)

testdma-$(BOARD): testdmacopy.o libdmac-$(BOARD).so
	g++ -O -o testdma-$(BOARD) testdmacopy.o -L. -ldmac-$(BOARD) -lpthread
