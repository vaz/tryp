# This is not tested at all.  It might work.

require 'ffi'

module Tryp
  class MIDI
    def open
      output_ptr = FFI::MemoryPointer.new :pointer
      C.snd_rawmidi_open nil, output_ptr, 'virtual', 0)
      @output = output_ptr.read_pointer
    end

    def close
      C.snd_rawmidi_close(@output)
    end

    def message(*args)
      bytes = FFI::MemoryPointer.new(FFI.type_size(:char) * args.size)
      bytes.write_string args.pack('C' * args.size)
      C.snd_rawmidi_write @output, bytes, args.size
      C.snd_rawmidi_drain @output
    end

    module C
      extend FFI::Library
      ffi_lib 'libasound.so'

      attach_function :snd_rawmidi_open,  [:pointer, :pointer, :pointer, :int], :int
      attach_function :snd_rawmidi_close, [:pointer],                           :int
      attach_function :snd_rawmidi_write, [:pointer, :pointer, :int],           :int
      attach_function :snd_rawmidi_drain, [:pointer],                           :int
    end
  end
end
