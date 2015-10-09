
CONNECTALDIR?=/home/jamey/connectal
DTOP?=/home/jamey/dmac/dma/bluesim

CFLAGS_COMMON = -O -g -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp -I/home/jamey/dmac/dma -I/home/jamey/dmac/dma -I/home/jamey/connectal/cpp -I/home/jamey/connectal/cpp  -DConnectalVersion=15.10.3 -DNumberOfMasters=1 -DPinType=Empty -DPinTypeInclude=Misc -DNumberOfUserTiles=1 -DSlaveDataBusWidth=32 -DSlaveControlAddrWidth=5 -DBurstLenSize=10 -DExportType= -DUSE_DUAL_CLOCK_FIFOF -Dproject_dir=$(DTOP) -DMainClockPeriod=20 -DDerivedClockPeriod=10.000000 -DBsimHostInterface -DPhysAddrWidth=40 -DSIMULATION -DBOARD_bluesim -Wall -Werror
CFLAGS = $(CFLAGS_COMMON)
CFLAGS2 = 

include $(DTOP)/Makefile.autotop
include $(CONNECTALDIR)/scripts/Makefile.connectal.application
SOURCES = /home/jamey/dmac/dma/testdmacopy.cpp /home/jamey/dmac/dma/dmac.cpp /home/jamey/connectal/cpp/dmaManager.c /home/jamey/connectal/cpp/platformMemory.cpp $(PORTAL_SRC_FILES)
SOURCES2 =  $(PORTAL_SRC_FILES)
XSOURCES = $(CONNECTALDIR)/cpp/XsimTop.cpp $(PORTAL_SRC_FILES)
LDLIBS :=    -pthread 

ubuntu.exe: $(SOURCES)
	$(Q)g++ $(CFLAGS) -o ubuntu.exe $(SOURCES) $(LDLIBS)
	$(Q)[ ! -f ../bin/mkTop.bin.gz ] || objcopy --add-section fpgadata=../bin/mkTop.bin.gz ubuntu.exe

connectal.so: $(SOURCES)
	$(Q)g++ -shared -fpic $(CFLAGS) -o connectal.so -DBSIM $(BSIM_EXE_CXX) $(SOURCES) $(LDLIBS)

ubuntu.exe2: $(SOURCES2)
	$(Q)g++ $(CFLAGS) $(CFLAGS2) -o ubuntu.exe2 $(SOURCES2) $(LDLIBS)

bsim_exe: $(SOURCES)
	$(Q)g++ $(CFLAGS_COMMON) -o bsim_exe -DBSIM $(SOURCES) $(BSIM_EXE_CXX) $(LDLIBS)

bsim_exe2: $(SOURCES2)
	$(Q)g++ $(CFLAGS_COMMON) $(CFLAGS2) -o bsim_exe2 -DBSIM $(SOURCES2) $(BSIM_EXE_CXX) $(LDLIBS)

xsim: $(XSOURCES)
	g++ $(CFLAGS) -o xsim $(XSOURCES)
