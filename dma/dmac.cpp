
#include "dmac.h"
#include "portal.h"
#include "dmaManager.h"
#include "DmaIndication.h"
#include "DmaRequest.h"
#include "LoopbackControl.h"

//fixme
extern int doRead;
extern int doWrite;
extern int numiters;
extern int numchannels;
extern int arraySize;
extern int burstLenBytes;

static int proxyNames[] = { IfcNames_DmaRequestS2H0, IfcNames_DmaRequestS2H1 };
static int wrapperNames[] = { IfcNames_DmaIndicationH2S0 , IfcNames_DmaIndicationH2S1 };

DmaManager *mgr;
void initDmaManager()
{
    if (!mgr)
	mgr = platformInit();
}


DmaBuffer::DmaBuffer(int size)
  : size(size), ref(-1)
{
    fd = portalAlloc(size, 1);
    buf = (char *)portalMmap(fd, size);
}

DmaBuffer::~DmaBuffer()
{
    dereference();
    portalMunmap(buf, size);
    close(fd);
}

int DmaBuffer::reference()
{
    initDmaManager();
    if (ref == -1)
	ref = mgr->reference(fd);
    return ref;
}

void DmaBuffer::dereference()
{
    if (ref != -1 && mgr)
	mgr->dereference(ref);
    ref = -1;
}

class DmaIndication : public DmaIndicationWrapper
{
    DmaChannel *channel;
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
    DmaIndication(unsigned int id, PortalPoller *poller = 0, DmaChannel *channel = 0)
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

DmaChannel::DmaChannel(int channel)
    : poller(new PortalPoller(0)), channel(channel), size(arraySize), waitCount(0)
{
    pthread_mutex_init(&channel_lock, 0);
    dmaRequest    = new DmaRequestProxy(proxyNames[channel], poller);
    dmaRequest->pint.busyType = BUSY_SPIN;
    dmaRequest->burstLen(burstLenBytes);
    dmaIndication = new DmaIndication(wrapperNames[channel], poller, this);
    fprintf(stderr, "[%s:%d] channel %d allocating buffers\n", __FUNCTION__, __LINE__, channel);
    for (int i = 0; i < 4; i++) {
	buffers[i] = new DmaBuffer(size);
    }
}

LoopbackControlProxy *loopbackControl;
void DmaChannel::post() {
  waitCount--;
  loopbackControl->marker(0xf00f);
}

volatile int started;
sem_t workersem;
void DmaChannel::run()
{
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
	checkIndications();
	//sleep(1);
    }
}

void DmaChannel::checkIndications()
{
    pthread_mutex_lock(&channel_lock);
    poller->event();
    pthread_mutex_unlock(&channel_lock);
}

int DmaChannel::read ( const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag )
{
    pthread_mutex_lock(&channel_lock);
    int v = dmaRequest->read(objId, base, bytes, tag);
    pthread_mutex_unlock(&channel_lock);
    return v;
}

int DmaChannel::write ( const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag )
{
    pthread_mutex_lock(&channel_lock);
    int v = dmaRequest->write(objId, base, bytes, tag);
    pthread_mutex_unlock(&channel_lock);
    return v;
}

void *DmaChannel::threadfn(void *c)
{
    DmaChannel *channelp = (DmaChannel *)c;
    while (!started) {
	// wait for other threads to be ready
    }
    channelp->run();
    sem_post(&workersem);
    return 0;
}

DmaController::DmaController()
{
    loopbackControl = new LoopbackControlProxy(IfcNames_LoopbackControlS2H);
    loopbackControl->loopback(0);
}

DmaController::~DmaController()
{
}

void DmaController::start()
{
    sem_init(&workersem, 0, 0);
    threads = new pthread_t[numchannels];
    for (int i = 0; i < numchannels; i++) {
      DmaChannel *channel = new DmaChannel(i);
      pthread_create(&threads[i], 0, channel->threadfn, channel);
    }
    started = 1;
}

void DmaController::wait()
{
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
}
