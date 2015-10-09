
DMADIR=../dma
CONNECTALDIR=$(realpath ../../connectal)

all: testdma-bluesim testdma-vc707g2

testdma-%:
	$(MAKE) CONNECTALDIR=$(CONNECTALDIR) BOARD=$(*) testdma-$(*)

connectal/portal.h:
	mkdir -p connectal

libdmac-$(BOARD).so: ../dmaso/$(BOARD)/bin/connectal.so
	cp ../dmaso/$(BOARD)/bin/connectal.so libdmac-$(BOARD).so
ifeq ($(BOARD),bluesim)
	cp -f ../dmaso/$(BOARD)/bin/bsim .
	cp -f ../dmaso/$(BOARD)/bin/bsim.so .
endif

../dmaso/$(BOARD)/bin/connectal.so:
ifeq ($(BOARD),bluesim)
	cd ../dmaso; pwd; make CONNECTALDIR=$(CONNECTALDIR) gen.$(BOARD); make -C $(BOARD) connectal.so bsim
else
	cd ../dmaso; pwd; make CONNECTALDIR=$(CONNECTALDIR) gen.$(BOARD) build.$(BOARD)
endif


testdmacopy.o: $(DMADIR)/testdmacopy.cpp
	g++ -O -c $(DMADIR)/testdmacopy.cpp

testdma-$(BOARD): testdmacopy.o libdmac-$(BOARD).so
	g++ -O -o testdma-$(BOARD) testdmacopy.o -L. -ldmac-$(BOARD) -lpthread
