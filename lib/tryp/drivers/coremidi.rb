# Based on code from Topher Cyll's rad book Practical Ruby Projects,
# but using ffi instead of dl.  Also got help from TMDAS, another
# project like this, who also uses ffi instead.

require 'ffi'

# pointer size lets us know if this is 64-bit (Snow Leopard)
ARCH_64_BIT = ['meow'].pack('p').size * 8 == 64

module Tryp
  class MIDI
    def open
      log "Opening MIDI connection"
      # Create MIDI client
      client_name = CF.CFStringCreateWithCString(nil, "TrypMIDI", 0)
      client_ptr = FFI::MemoryPointer.new(:pointer)
      C.MIDIClientCreate(client_name, nil, nil, client_ptr)
      @client = client_ptr.read_pointer

      # Create MIDI output port
      port_name = CF.CFStringCreateWithCString(nil, "Output", 0)
      outport_ptr = FFI::MemoryPointer.new(:pointer)
      C.MIDIOutputPortCreate(@client, port_name, outport_ptr)
      @outport = outport_ptr.read_pointer

      # Get first available MIDI destination or die
      destinations = C.MIDIGetNumberOfDestinations
      log "Found #{destinations} destinations, choosing first"
      raise NoMIDIDestinations if destinations < 1
      @destination = C.MIDIGetDestination(0)
    end

    def close
      log "Closing MIDI connection"
      C.MIDIClientDispose(@client)
    end

    def message(*args)
      bytes = FFI::MemoryPointer.new(FFI.type_size(:char) * args.size)
      bytes.write_string args.pack('C' * args.size)
      packet_list = FFI::MemoryPointer.new(256)
      packet_ptr = C.MIDIPacketListInit(packet_list)

      if ARCH_64_BIT
        packet_ptr = C.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, args.size, bytes)
      else
        packet_ptr = C.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, 0, args.size, bytes)
      end

      C.MIDISend(@outport, @destination, packet_list)
    end


    class NoMIDIDestinations < Exception; end

    # CoreMIDI external functions
    module C

      extend FFI::Library
      ffi_lib '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'

      attach_function :MIDIClientCreate,            [:pointer] * 4, :int
      attach_function :MIDIClientDispose,           [:pointer],     :int 
      attach_function :MIDIGetNumberOfDestinations, [],             :int
      attach_function :MIDIGetDestination,          [:int],         :pointer
      attach_function :MIDIOutputPortCreate,        [:pointer] * 3, :int
      attach_function :MIDIPacketListInit,          [:pointer],     :pointer

      # In 32-bit systems, the time arg was specified by two ints, because it was a 64 bit value.
      # Since Snow Leopard, we only need one int to hold it.
      time_arg = ARCH_64_BIT ? [:int] : [:int, :int]
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer] + time_arg + [:int, :pointer], :int

      attach_function :MIDISend,                    [:pointer] * 3, :int
    end

    # CoreFoundation external functions
    module CF
      extend FFI::Library
      ffi_lib '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation'

      attach_function :CFStringCreateWithCString, [:pointer, :pointer, :int], :pointer 
    end
  end
end
