Dma C++ References
==================

To use these classes::

    #include <dmac.h>


DmaBuffer Class
----------------

.. cpp:class:: DmaBuffer

   Represents a portal memory object which may be shared between
   software and hardware.  

   .. cpp:function:: DmaBuffer::DmaBuffer(int size)

      Allocates a portal memory object of the specified size and maps
      it into the user process.

   .. cpp:function:: char *DmaBuffer::buffer()

      Returns the pointer to the mapped memory.

   .. cpp:function:: int reference()

      Returns an object identifier for the object to pass to DMA
      controller (via :cpp:ref:`DmaChannel::read` or
      :cpp:ref:`DmaChannel::write`) and sends the address translation
      table to the FPGA's MMU. Up to 32 objects may be mapped at one
      time.

   .. cpp:function:: void dereference()

      Unmaps the object from the hardware.


DmaChannel Class
----------------

.. cpp:class:: DmaChannel

   Controls one DMA channel.

   .. cpp:function:: DmaChannel::DmaChannel(int channelNum, DmaCallback *callbacks = 0)

      Connects to the specified DMA channel on the FPGA. Notifies completion of requests via the callbacks pointer.

   .. cpp:function:: void checkIndications()

      Checks for notification of completion of DMA requests.

      Thread safe.

   .. cpp:function:: int read ( const uint32_t objref, const uint32_t base, const uint32_t bytes, const uint8_t tag )

      Issues a DMA read request on this channel.

       * :cpp:var:`objref` is the identifier returned from :cpp:member:`DmaBuffer::reference`.
       * :cpp:var:`base` is offset, in bytes, from which to start reading.
       * :cpp:var:`numbytes` is the number of bytes to read.
       * :cpp:var:`tag` is an opaque identifer used to identify this request when invoking :cpp:func:`DmaCallback::readDone`.

      Thread safe.

   .. cpp:function:: int write ( const uint32_t objref, const uint32_t base, const uint32_t bytes, const uint8_t tag )

      Issues a DMA write request on this channel.

       * :cpp:var:`objref` is the identifier returned from :cpp:member:`DmaBuffer::reference`.
       * :cpp:var:`base` is offset, in bytes, at which to start writing.
       * :cpp:var:`numbytes` is the number of bytes to write.
       * :cpp:var:`tag` is an opaque identifer used to identify this request when invoking :cpp:func:`DmaCallback::writeDone`.

      Thread safe.

DmaCallback Class
-----------------

.. cpp:class:: DmaCallback

   Receives notifications that DMA read and write requests are completed.

   .. cpp:function:: virtual void DmaCallback::readDone ( uint32_t objref, uint32_t base, const uint8_t tag, uint32_t cycles )

      DmaChannel calls readDone from
      :cpp:member:`DmaChannel::checkIndications` when it is notified
      that a DMA read request has completed.  The first three
      parameters, :cpp:var:`objref`, :cpp:var:`base`, and
      :cpp:var:`tag` match the corresponding call to
      :cpp:member:`DmaChannel::read`.


   .. cpp:function:: virtual void DmaCallback::writeDone ( uint32_t objref, uint32_t base, uint8_t tag, uint32_t cycles )

      DmaChannel calls writeDone from
      :cpp:member:`DmaChannel::checkIndications` when it is notified
      that a DMA write request has completed. The first three
      parameters, :cpp:var:`objref`, :cpp:var:`base`, and
      :cpp:var:`tag` match the corresponding call to
      :cpp:member:`DmaChannel::write`.
