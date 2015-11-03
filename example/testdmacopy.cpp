/* Copyright (c) 2015 Connectal Project
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

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
int numiters = 1;
int burstLenBytes = 128;

class ChannelWorker : public DmaCallback {
    DmaChannel *channel;
    int channelNumber;
    int waitCount;
    DmaBuffer *buffers[4];
    static void *threadfn(void *c);
    void run();

    static int started;
    static pthread_t *threads;

public:
    ChannelWorker(int channelNumber)
    : channelNumber(channelNumber), waitCount(0) {

	channel = new DmaChannel(channelNumber, this);

	fprintf(stderr, "[%s:%d] channel %d allocating buffers\n", __FUNCTION__, __LINE__, channelNumber);
	for (int i = 0; i < 4; i++) {
	    buffers[i] = new DmaBuffer(arraySize);
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
	cycles *= -1;
	fprintf(stderr, "[%s:%d] sglId=%d base=%08x tag=%d cycles=%d read bandwidth %5.2f MB/s link utilization %5.2f%%\n",
		__FUNCTION__, __LINE__, sglId, base, tag, cycles, 16*250*linkUtilization(cycles), 100.0*linkUtilization(cycles, 1));
	waitCount--;
    }
    void writeDone ( uint32_t sglId, uint32_t base, uint8_t tag, uint32_t cycles ) {
	cycles *= -1;
	fprintf(stderr, "[%s:%d] sglId=%d base=%08x tag=%d cycles=%d write bandwidth %5.2f MB/s link utilization %5.2f%%\n",
		__FUNCTION__, __LINE__, sglId, base, tag, cycles, 16*250*linkUtilization(cycles), 100.0*linkUtilization(cycles, 1));
	waitCount--;
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
    for (int i = 0; i < numiters; i++) {
	if (doRead) {
	    fprintf(stderr, "[%s:%d] channel %d requesting dma read size=%d\n", __FUNCTION__, __LINE__, channelNumber, arraySize);
	    int tag = waitCount % 4;
	    channel->read(buffers[0]->reference(), 0, arraySize, tag);
	    waitCount++;
	}

	if (doWrite) {
	    fprintf(stderr, "[%s:%d] channel %d requesting dma write size=%d\n", __FUNCTION__, __LINE__, channelNumber, arraySize);
	    int tag = waitCount % 4;
	    channel->write(buffers[1]->reference(), 0, arraySize, tag);
	    waitCount++;
	}
    }
    fprintf(stderr, "[%s:%d] channel %d waiting for responses\n", __FUNCTION__, __LINE__, channelNumber);
    while (waitCount > 0) {
      channel->checkIndications();
    }
}

int ChannelWorker::started = 0;
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
	    if (burstLenBytes > 128)
	      burstLenBytes = 128;
	    break;
	case 'i':
	    numiters = strtoul(optarg, 0, 0);
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
