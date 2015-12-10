Example Application
===================

The application consists of two pieces, user software that runs on the PC and user logic that runs on the FPGA.

Example.bsv
-----------

Here is simple user logic for the FPGA::

    `include "ConnectalProjectConfig.bsv"

    import FIFOF::*;
    import GetPut::*;
    import Connectable::*;
    import ConnectalConfig::*;

    import PcieDma::*;

    interface Example;
       interface PciePins pcie;
    endinterface

    `ifndef BOARD_bluesim
    (* no_default_clock, no_default_reset *)
    `endif
    module mkExample
    `ifndef BOARD_bluesim
    #(Clock pci_sys_clk_p, Clock pci_sys_clk_n, Reset pci_sys_reset_n)
    `endif
    (Example);

       PcieDma pcieDma <- mkPcieDma(
    `ifndef BOARD_bluesim
	  pci_sys_clk_p, pci_sys_clk_n, pci_sys_reset_n
    `endif
	  );
       let clock = pcieDma.clock();
       let reset = pcieDma.reset();

       for (Integer channel = 0; channel < valueOf(NumChannels); channel = channel + 1) begin
	  Reg#(Bit#(16)) iter <- mkReg(0, clocked_by clock, reset_by reset);
	  rule toFpgaRule;
	     PipeOut#(MemDataF#(DataBusWidth)) toFpgaPipe = pcieDma.toFpga[channel];
	     MemDataF#(DataBusWidth) md = toFpgaPipe.first();
	     toFpgaPipe.deq();
	     // insert code here to consume md
	  endrule
	  rule fromFpgaRule;
	     // placeholder code to produce md
	     // tag, first, and last are not checked by the library
	     MemDataF#(DataBusWidth) md = MemDataF {data: ('hdada << 32) | (fromInteger(channel) << 16) | extend(iter),
						    tag: 0, first: False, last: False};
	     PipeIn#(MemDataF#(DataBusWidth)) fromFpgaPipe = pcieDma.fromFpga[channel];
	     fromFpgaPipe.enq(md);
	     iter <= iter + 1;
	  endrule
       end

       interface pcie = pcieDma.pcie;

    endmodule

Example.cpp
-----------

Here is the corresponding user software::

    #include <stdio.h>
    #include <sys/mman.h>
    #include <string.h>
    #include <stdlib.h>
    #include <unistd.h>
    #include <pthread.h>
    #include <semaphore.h>

    #include "dmac.h"

    #ifdef SIMULATION
    int arraySize = 4*1024;
    #else
    int arraySize = 128*1024;
    #endif
    int doWrite = 1;
    int doRead = 1;
    int numchannels = 1;
    int numIters = 10;
    int burstLenBytes = 256;

    class ChannelWorker : public DmaCallback {
	DmaChannel *channel;
	int channelNumber;
	int numReads;
	int numWrites;
	int waitCount;
	DmaBuffer *buffers[4];
	static void *threadfn(void *c);
	void run();

	static volatile int started;
	static pthread_t *threads;

    public:
	ChannelWorker(int channelNumber)
	: channelNumber(channelNumber), numReads(0), numWrites(0), waitCount(0) {

	    channel = new DmaChannel(channelNumber, this);

	    fprintf(stderr, "[%s:%d] channel %d allocating buffers\n", __FUNCTION__, __LINE__, channelNumber);
	    for (int i = 0; i < 4; i++) {
		buffers[i] = new DmaBuffer(arraySize);
		memset(buffers[i]->buffer(), 0xba, arraySize);
	    }
	}

	double linkUtilization(uint32_t cycles, int inclHeaders = 0) {
	    double dataBeats = (double)arraySize/16;
	    int headerBeats = 0;
	    if (inclHeaders) {
		headerBeats = arraySize / burstLenBytes;
	    }
	    double totalBeats = dataBeats + headerBeats;
	    return totalBeats / (double)cycles;
	}
	void readDone ( uint32_t sglId, uint32_t base, const uint8_t tag, uint32_t cycles ) {
	    fprintf(stderr, "[%s:%d] sglId=%d base=%08x tag=%d burstLenBytes=%d cycles=%d read bandwidth %5.2f MB/s link utilization %5.2f%%\n",
		    __FUNCTION__, __LINE__, sglId, base, tag, burstLenBytes, cycles, 16*250*linkUtilization(cycles), 100.0*linkUtilization(cycles, 1));
	    if (numReads) {
		fprintf(stderr, "[%s:%d] channel %d requesting dma read size=%d\n", __FUNCTION__, __LINE__, channelNumber, arraySize);
		int tag = 0;
		channel->read(buffers[0]->reference(), 0, arraySize, tag);
		numReads--;
	    } else {
		waitCount--;
		fprintf(stderr, "[%s:%d] channel %d waiting for %d responses\n", __FUNCTION__, __LINE__, channelNumber, waitCount);
	    }
	}
	void writeDone ( uint32_t sglId, uint32_t base, uint8_t tag, uint32_t cycles ) {
	    fprintf(stderr, "[%s:%d] sglId=%d base=%08x tag=%d burstLenBytes=%d cycles=%d write bandwidth %5.2f MB/s link utilization %5.2f%%\n",
		    __FUNCTION__, __LINE__, sglId, base, tag, burstLenBytes, cycles, 16*250*linkUtilization(cycles), 100.0*linkUtilization(cycles, 1));
	    if (0)
	    for (int i = 0; i < 4; i++) {
	      if (buffers[i]->reference() == sglId) {
		for (int j = 0; j < 8; j++) {
		  fprintf(stderr, "%d: %016lx\n", j, *(uint64_t *)(buffers[i]->buffer() + j*8));
		}
	      }
	    }
	    if (numWrites) {
		fprintf(stderr, "[%s:%d] channel %d requesting dma write size=%d\n", __FUNCTION__, __LINE__, channelNumber, arraySize);
		int tag = 1;
		channel->write(buffers[1]->reference(), 0, arraySize, tag);
		numWrites--;
	    } else {
		waitCount--;
		fprintf(stderr, "[%s:%d] channel %d waiting for %d responses\n", __FUNCTION__, __LINE__, channelNumber, waitCount);
	    }
	}
	static void runTest();
    };

    void *ChannelWorker::threadfn(void *c)
    {
	ChannelWorker *worker = (ChannelWorker *)c;
	while (!started) {
	    // wait for other threads to be ready
	}
	worker->run();
	return 0;
    }

    void ChannelWorker::run()
    {
	channel->setBurstLen(burstLenBytes);
	for (int i = 0; i < 2; i++) {
	    if (i == 0) {
		numReads = numIters;
		numWrites = 0;
	    } else {
		numReads = 0;
		numWrites = numIters;
	    }
	    if (numReads) {
		fprintf(stderr, "[%s:%d] channel %d requesting dma read size=%d\n", __FUNCTION__, __LINE__, channelNumber, arraySize);
		int tag = 0;
		channel->read(buffers[0]->reference(), 0, arraySize, tag);
		waitCount++;
		numReads--;
	    }

	    if (numWrites) {
		fprintf(stderr, "[%s:%d] channel %d requesting dma write size=%d\n", __FUNCTION__, __LINE__, channelNumber, arraySize);
		int tag = 1;
		channel->write(buffers[1]->reference(), 0, arraySize, tag);
		waitCount++;
		numWrites--;
	    }
	    fprintf(stderr, "[%s:%d] channel %d waiting for responses\n", __FUNCTION__, __LINE__, channelNumber);
	    while (waitCount > 0) {
		channel->checkIndications();
	    }
	    waitCount = 0;
	}
    }

    volatile int ChannelWorker::started = 0;
    pthread_t *ChannelWorker::threads = 0;

    void ChannelWorker::runTest()
    {
	started = 0;
	threads = new pthread_t[numchannels];
	for (int i = 0; i < numchannels; i++) {
	    ChannelWorker *worker = new ChannelWorker(i);
	    pthread_create(&threads[i], 0, worker->threadfn, worker);
	}
	started = 1;

	// let test run

	// wait for threads to exit
	for (int i = 0; i < numchannels; i++) {
	  void *ret;
	  pthread_join(threads[i], &ret);
	  fprintf(stderr, "thread exited ret=%p\n", ret);
	}
    }

    int main(int argc, char * const*argv)
    {
	int opt;
	while ((opt = getopt(argc, argv, "b:i:rws:")) != -1) {
	    switch (opt) {
	    case 'r':
		doWrite = 0;
		break;
	    case 'w':
		doRead = 0;
		break;
	    case 'b':
		burstLenBytes = strtoul(optarg, 0, 0);
		if (burstLenBytes > 1024)
		  burstLenBytes = 1024;
		break;
	    case 'i':
		numIters = strtoul(optarg, 0, 0);
		break;
	    case 's': {
		char *endptr = 0;
		arraySize = strtoul(optarg, &endptr, 0);
		if (endptr) {
		    switch (*endptr) {
		    case 'K':
			arraySize *= 1024;
			break;
		    case 'M':
			arraySize *= 1024*1024;
			break;
		    default:
			break;
		    }
		}
	    } break;
	    default:
		fprintf(stderr,
			"Usage: %s [-r] [-w] [-s transferSize]\n"
			"       -r read only\n"
			"       -r write only\n",
			argv[0]);
		exit(EXIT_FAILURE);
	    }
	}
	ChannelWorker::runTest();
	return 0;
    }

