
PREFIX?=/usr/local
CONNECTALDIR?=connectal

all: bsvtops
	$(MAKE) BOARD=vc709 libdmac-vc709.so
	$(MAKE) BOARD=bluesim libdmac-bluesim.so

install: all
	install -d -m755 $(DESTDIR)$(PREFIX)/include/dmac $(DESTDIR)$(PREFIX)/lib $(DESTDIR)$(PREFIX)/share/dmac/bsv $(DESTDIR)$(PREFIX)/share/dmac/tcl
	install -m644 Makefile.dmac $(DESTDIR)$(PREFIX)/share/dmac
	install -m644 dmac.h $(DESTDIR)$(PREFIX)/include/dmac
	install -m644 lib*.so $(DESTDIR)$(PREFIX)/lib
	install -m644 *.bsv top/*.bsv generated/*.bsv $(DESTDIR)$(PREFIX)/share/dmac/bsv
	install -m644 pciecore.tcl $(DESTDIR)$(PREFIX)/share/dmac/tcl

bsvtops: generated/BsimTop.bsv generated/PcieTop.bsv

generated/%.bsv: $(CONNECTALDIR)/bsv/%.bsv
	cp -fv $< $@
	sed -i 's/import Top *::/import ConnectalTop::/' $@

PORTAL_INFRA := portal.c transportHardware.c transportSocket.c portalJson.c portalPrintf.c poller.cpp sock_utils.c timer.c dmaManager.c platformMemory.cpp BsimCtrl.cpp BsimDma.cpp
GENERATED_CPP=GeneratedCppCallbacks.cpp MemServerRequest.c MemServerRequestJson.c MMURequest.c MMURequestJson.c MemServerIndication.c MemServerIndicationJson.c MMUIndication.c MMUIndicationJson.c DmaRequest.c DmaRequestJson.c DmaIndication.c DmaIndicationJson.c
PORTAL_SRC_FILES := $(addprefix $(CONNECTALDIR)/cpp/, $(PORTAL_INFRA)) \
                    $(addprefix ../src/generated/, $(GENERATED_CPP))
SOURCES = ../src/dmac.cpp $(PORTAL_SRC_FILES)
OBJECTS = $(addsuffix .o, $(PORTAL_INFRA) $(GENERATED_CPP))

CFLAGS = -I../src -I$(CONNECTALDIR)/cpp -I../src/generated -I$(CONNECTALDIR)
ifeq ($(BOARD),bluesim)
CFLAGS += -DSIMULATION -DSIMULATOR_USE_PATH
endif

libdmac-%.so: $(PORTAL_SRC_FILES)
	$(Q)g++ -shared -fpic $(CFLAGS) -DBOARD_$(*) -o $@ $(SOURCES)

connectalsrc:
	mkdir -p connectal/cpp connectal/bsv connectal/drivers/portalmem connectal/drivers/pcieportal connectal/verilog connectal/constraints
	cp $(CONNECTALDIR)/bsv/*.bsv connectal/bsv
	cp $(CONNECTALDIR)/lib/bsv/*.bsv connectal/bsv
	cp $(CONNECTALDIR)/generated/xilinx/*.bsv connectal/bsv
	cp $(CONNECTALDIR)/cpp/* connectal/cpp
	cp $(CONNECTALDIR)/drivers/portalmem/*.h connectal/drivers/portalmem
	cp $(CONNECTALDIR)/drivers/pcieportal/*.h connectal/drivers/pcieportal
	cp $(CONNECTALDIR)/verilog/*.v connectal/verilog
	cp $(CONNECTALDIR)/constraints/xilinx/*.xdc connectal/constraints
