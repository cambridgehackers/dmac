
#include <pthread.h>
#include <semaphore.h>
#include <GeneratedTypes.h>

class DmaManager;

class DmaBuffer {
    const int size;
    int fd;
    char *buf;
    int ref;
public:
    // Allocates a portal memory object of specified size and maps it into user process
    DmaBuffer(int size);
    // Dereferences and deallocates the portal memory object
    // if destructor is not called, the object is automatically
    // unreferenced and freed when the process exits
    ~DmaBuffer();
    // returns the address of the mapped buffer
    char *buffer() {
	return buf;
    }
    // returns the reference to the object
    //
    // Sends the address translation table to hardware MMU if necessary.
    int reference();
    // Removes the address translation table from the hardware MMU
    void dereference();
};

class DmaCallback {
public:
    DmaCallback() {}
    virtual ~DmaCallback() {}
    virtual void readDone ( uint32_t sglId, uint32_t base, const uint8_t tag, uint32_t cycles ) = 0;
    virtual void writeDone ( uint32_t sglId, uint32_t base, uint8_t tag, uint32_t cycles ) = 0;
};

class DmaIndication;
class DmaRequestProxy;
class PortalPoller;

// DmaChannel processes one channel
class DmaChannel {
  pthread_mutex_t channel_lock;
  PortalPoller *poller;
  DmaIndication *dmaIndication;
  DmaRequestProxy *dmaRequest;
  int channel;
  volatile int waitCount;
  friend class DmaIndication;
  friend class DmaController;
  static void *threadfn(void *c);
public:
    DmaChannel(int channel, DmaCallback *callbacks = 0);
    void run();
    void checkIndications();
    int read ( const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag );
    int write ( const uint32_t objId, const uint32_t base, const uint32_t bytes, const uint8_t tag );
};
