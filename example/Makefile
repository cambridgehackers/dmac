
DTOP=.

BSVDEFINES =  -D ConnectalVersion=15.10.3 -D NumberOfMasters=1 -D PinType=DmaTopPins -D PinTypeInclude=DmaTopPins -D NumberOfUserTiles=1 -D SlaveDataBusWidth=32 -D SlaveControlAddrWidth=5 -D BurstLenSize=10 -D ExportType= -D USE_DUAL_CLOCK_FIFOF -D project_dir=$(DTOP) -D MainClockPeriod=4 -D DerivedClockPeriod=4.000000 -D PcieClockPeriod=4 -D XILINX=1 -D Virtex7 -D PCIE -D PCIE3 -D PcieHostInterface -D PhysAddrWidth=40 -D NUMBER_OF_LEDS=8 -D BOARD_vc709

BSCWARNFLAGS += -demote-errors G0066:G0045 -suppress-warnings G0046:G0020:S0015:S0080:S0039:T0127

BSCFLAGS_COMMON += +RTS -K46777216 -RTS
BSCOPTFLAGS= -show-schedule -aggressive-conditions
BSCPATHFLAGS=  -bdir $(DTOP)/obj -vdir $(DTOP)/verilog -simdir $(DTOP)/obj -info-dir $(DTOP)/obj -p +:../src:../src/connectal:../src/generated
BSCFLAGS_COMMON += $(BSCWARNFLAGS) $(BSCOPTFLAGS) $(BSCPATHFLAGS) --wait-for-license
BSCFLAGS_COMMON += -D ClockDefaultParam

verilog/mkExample.v: Example.bsv
	mkdir -p obj verilog
	bsc $(BSVDEFINES) $(BSCFLAGS_COMMON) -u -verilog -g mkExample Example.bsv
