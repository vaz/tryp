# This is not tested at all.  It might work.

require 'ffi'

module Tryp
  class MIDI
    def open
      device_ptr = FFI::MemoryPointer.new(FFI.type_size(:int))
      C.midiOutOpen device_ptr, -1, 0, 0, 0)
      @device = device_ptr.read_int
    end

    def close
      C.midiOutClose @device
    end

    def message(one, two=0, three=0)
      message = one + (two << 8) + (three << 16)
      C.midiOutShortMsg @device, message
    end

    module C
      extend FFI::Library
      ffi_lib 'winmm'

      attach_function :midiOutOpen, [:pointer] + [:int] * 4, :int
      attach_function :midiOutClose, [:int], :int
      attach_function :midiOutShortMsg, [:int]*2, :int
    end
  end
end
