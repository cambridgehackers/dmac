
DMADIR=../dma

all: testdma-bluesim testdma-vc707

testdma-%:
	$(MAKE) BOARD=$(*) testdma-$(*)

connectal/portal.h:
	mkdir -p connectal

libdmac-$(BOARD).so: ../dmaso/$(BOARD)/bin/connectal.so
	cp ../dmaso/$(BOARD)/bin/connectal.so libdmac-$(BOARD).so
ifeq ($(BOARD),bluesim)
	cp -f ../dmaso/$(BOARD)/bin/bsim .
	cp -f ../dmaso/$(BOARD)/bin/bsim.so .
endif

../dmaso/$(BOARD)/bin/connectal.so:
	cd ../dmaso; pwd; make gen.$(BOARD); make -C $(BOARD) connectal.so bsim


testdmacopy.o: $(DMADIR)/testdmacopy.cpp
	g++ -O -c $(DMADIR)/testdmacopy.cpp

testdma-$(BOARD): testdmacopy.o libdmac-$(BOARD).so
	g++ -O -o testdma-$(BOARD) testdmacopy.o -L. -ldmac-$(BOARD) -lpthread
