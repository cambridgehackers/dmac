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
// the next 3 should be hidden in dmac.cpp
#include "dmaManager.h"
#include "DmaIndication.h"
#include "DmaRequest.h"
#include "LoopbackControl.h"


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

class DmaIndication;
LoopbackControlProxy *loopbackControl;
static int proxyNames[] = { IfcNames_DmaRequestS2H0 
			    , IfcNames_DmaRequestS2H1 
};
static int wrapperNames[] = { IfcNames_DmaIndicationH2S0
			      , IfcNames_DmaIndicationH2S1 
};

pthread_t threads[2];

// ChannelWorker processes one channel
class ChannelWorker {
  PortalPoller *poller;
  DmaIndication *dmaIndication;
  DmaRequestProxy *dmaRequest;
  int channel;
  DmaBuffer *buffers[4];
  int size;
  volatile int waitCount;
public:
    ChannelWorker(int channel);
    void run();
    void post() {
      waitCount--;
      loopbackControl->marker(0xf00f);
    }
    static void *threadfn(void *c);
};

class DmaIndication : public DmaIndicationWrapper
{
    ChannelWorker *channel;
    sem_t sem;
  int count;
  void incr_count() {
    count--;
    if (channel)
      channel->post();
    if (count <= 0) {
      //sem_post(&sem);
    }
  }
public:
    DmaIndication(unsigned int id, PortalPoller *poller = 0, ChannelWorker *channel = 0)
      : DmaIndicationWrapper(id, poller), channel(channel), count(4) {
      //sem_init(&sem, 0, 0);
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
      //sem_post(&sem);
      incr_count();
    }
    void writeDone ( uint32_t sglId, uint32_t base, uint8_t tag, uint32_t cycles ) {
	cycles *= -1;
	fprintf(stderr, "[%s:%d] sglId=%d base=%08x tag=%d cycles=%d write bandwidth %5.2f MB/s link utilization %5.2f%%\n",
		__FUNCTION__, __LINE__, sglId, base, tag, cycles, 16*250*linkUtilization(cycles), 100.0*linkUtilization(cycles, 1));
      //sem_post(&sem);
      incr_count();
    }
    void wait() {
	sem_wait(&sem);
    }
};

ChannelWorker::ChannelWorker(int channel)
    : poller(new PortalPoller(0)), channel(channel), size(arraySize), waitCount(0)
{
    dmaRequest    = new DmaRequestProxy(proxyNames[channel], poller);
    dmaRequest->pint.busyType = BUSY_SPIN;
    dmaRequest->burstLen(burstLenBytes);
    dmaIndication = new DmaIndication(wrapperNames[channel], poller, this);
    fprintf(stderr, "[%s:%d] channel %d allocating buffers\n", __FUNCTION__, __LINE__, channel);
    for (int i = 0; i < 4; i++) {
	buffers[i] = new DmaBuffer(size);
    }
  }

volatile int started;
sem_t workersem;
void ChannelWorker::run()
{
    while (!started) {
	// wait for other threads to be ready
    }

    portalTimerStart(0);
    for (int i = 0; i < numiters; i++) {
	if (doRead) {
	    fprintf(stderr, "[%s:%d] channel %d requesting first dma size=%d\n", __FUNCTION__, __LINE__, channel, size);
	    dmaRequest->read(buffers[0]->reference(), 0, size, 0);
	    waitCount++;
	}

	if (doWrite) {
	    dmaRequest->write(buffers[1]->reference(), 0, size, 1);
	    waitCount++;
	}
    }
    fprintf(stderr, "[%s:%d] channel %d waiting for responses\n", __FUNCTION__, __LINE__, channel);
    // poll
    while (waitCount > 0) {
	poller->event();
	//sleep(1);
    }
    sem_post(&workersem);
}

void *ChannelWorker::threadfn(void *c)
{
    ChannelWorker *channelp = (ChannelWorker *)c;
    channelp->run();
    return 0;
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
    loopbackControl = new LoopbackControlProxy(IfcNames_LoopbackControlS2H);
    loopbackControl->loopback(0);

    sem_init(&workersem, 0, 0);
    for (int i = 0; i < numchannels; i++) {
      ChannelWorker *channel = new ChannelWorker(i);
      pthread_create(&threads[i], 0, channel->threadfn, channel);
    }
    started = 1;
    // wait for threads to exit
    for (int i = 0; i < numchannels; i++) {
      sem_wait(&workersem);
    }

    // wait for threads to exit
    for (int i = 0; i < numchannels; i++) {
      void *ret;
      pthread_join(threads[i], &ret);
      fprintf(stderr, "thread exited ret=%p\n", ret);
    }
    return 0;
}
