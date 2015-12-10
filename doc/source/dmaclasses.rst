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
      controller (via :cpp:member:`DmaChannel::read` or
      :cpp:member:`DmaChannel::transferFromFpga`) and sends the address translation
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

   .. cpp:function:: int transferToFpga ( const uint32_t objref, const uint32_t base, const uint32_t bytes, const uint8_t tag )

      Issues a DMA transferToFpga request on this channel.

       * :cpp:var:`objref` is the identifier returned from :cpp:member:`DmaBuffer::reference`.
       * :cpp:var:`base` is offset, in bytes, from which to start reading.
       * :cpp:var:`numbytes` is the number of bytes to read.
       * :cpp:var:`tag` is an opaque identifer used to identify this request when invoking :cpp:func:`DmaCallback::transferToFpgaDone`.

      Thread safe.

   .. cpp:function:: int transferFromFpga ( const uint32_t objref, const uint32_t base, const uint32_t bytes, const uint8_t tag )

      Issues a DMA transferFromFpga request on this channel.

       * :cpp:var:`objref` is the identifier returned from :cpp:member:`DmaBuffer::reference`.
       * :cpp:var:`base` is offset, in bytes, at which to start writing.
       * :cpp:var:`numbytes` is the number of bytes to write.
       * :cpp:var:`tag` is an opaque identifer used to identify this request when invoking :cpp:func:`DmaCallback::transferFromFpgaDone`.

      Thread safe.

DmaCallback Class
-----------------

.. cpp:class:: DmaCallback

   Receives notifications that DMA transferToFpga and transferFromFpga requests are completed.

   .. cpp:function:: virtual void DmaCallback::transferToFpgaDone ( uint32_t objref, uint32_t base, const uint8_t tag, uint32_t cycles )

      DmaChannel calls transferToFpgaDone from
      :cpp:member:`DmaChannel::checkIndications` when it is notified
      that a DMA transferToFpga request has completed.  The first three
      parameters, :cpp:var:`objref`, :cpp:var:`base`, and
      :cpp:var:`tag` match the corresponding call to
      :cpp:member:`DmaChannel::transferToFpga`.


   .. cpp:function:: virtual void DmaCallback::transferFromFpgaDone ( uint32_t objref, uint32_t base, uint8_t tag, uint32_t cycles )

      DmaChannel calls transferFromFpgaDone from
      :cpp:member:`DmaChannel::checkIndications` when it is notified
      that a DMA transferFromFpga request has completed. The first three
      parameters, :cpp:var:`objref`, :cpp:var:`base`, and
      :cpp:var:`tag` match the corresponding call to
      :cpp:member:`DmaChannel::transferFromFpga`.
