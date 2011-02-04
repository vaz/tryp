module Tryp
  class Note
    include Comparable

    attr_accessor :value, :cents
    
    NOTE_REGEX = %r{
      (?<prime>       [A-Ga-g])
      (?<accidental>  \# | b | s(?:harp)? | flat)?
      (?<octave>      -?\d)?
    }x

    PRIME_BASES = ['C', nil, 'D', nil, 'E', 'F', nil, 'G', nil, 'A', nil, 'B']

    # Note.new(60)      # => MIDI note 60 (middle C or C4)
    # Note.new('C4')    # => MIDI note 60 (C4)
    # Note.new('C#4')   # => MIDI note 61, etc.
    # Note.new(:Cs4')   # => MIDI note 61.
    # Note.new(:C4)     # => MIDI note 60.
    # Note.new(440.0)   # => MIDI note 69, concert A4 (440 Hz)
    def initialize value
      if value.is_a? Integer then return from_i value end
      if value.is_a? Symbol then return from_sym value end
      if value.is_a? Float then return from_f value end
      return from_s value.to_s
    end

    def eql? other; hash == other.to_note.hash end
    def <=> other; @value <=> other.to_note.value end
    def hash; @value end

    def + other; Note.new(@value + other) end
    def - other; Note.new(@value - other) end

    # even though we're dealing with midi note number,
    # mult/div should be as if it's frequency (so *2 is one octave up)
    def * other; Note.new(self.to_f * other) end
    def / other; Note.new(self.to_f / other) end

    def sharpen; Note.new(@value + 1) end
    def flatten; Note.new(@value - 1) end
    def sharpen!; @value += 1; self end
    def flatten!; @value -= 1; self end

    def to_note; self end
    def to_i; @value end
    def to_sym; self.to_s.to_sym end

    def to_s
      @name ||= begin
        octave, rest = @value.divmod(12)
        octave -= 1
        accidental, prime = '', PRIME_BASES[rest]
        accidental, prime = '#', PRIME_BASES[rest - 1] if prime.nil?
        "#{prime}#{accidental}#{octave}"
      end
    end

    # midi note number to frequency
    # equal temperament, based around A4 = 69 = 440Hz
    # f = 2**(n/12) * 440
    def to_f
      2**((@value-69)/12.0) * 440
    end


    private

    def from_i i
      if (0..127) === i
        @value = i
      else
        raise ArgumentError, "#{i} not in (0..127)"
      end
    end

    def from_sym(sym)
      from_s sym.to_s
    end

    # C4 is 60, C-1 is 0
    def from_s s
      m = NOTE_REGEX.match(s)
      raise ArgumentError, "#{s} fails the regex" if m.nil?
      prime, accidental, octave = m[:prime].upcase, m[:accidental], m[:octave]
      @value = 12 * (octave.to_i + 1) + PRIME_BASES.index(prime)
      case accidental.downcase
      when '#', 's', 'sharp' then sharpen!
      when 'b', 'flat' then flatten!
      else raise ArgumentError, "bad accidental #{accidental}"
      end unless accidental.nil?
    end

    # frequency to midi note
    # equal temperament, preserves cents in ivar (unused so far)
    # n = 69 + 12 * log2(f/440)
    # this is maybe kind of slow ok? don't abuse it. else make it faster.
    def from_f f
      value = 69 + 12 * (Math.log(f/440.0) / Math.log(2))
      _, cents = value.divmod(value.to_i)
      @value, @cents = value, (cents * 100).round
    end
  end

  class InvalidNoteError < Exception; end

  module NoteConvertible
    def to_note
      Note.new self
    end
  end
end

Symbol.send :include, Tryp::NoteConvertible
String.send :include, Tryp::NoteConvertible
Integer.send :include, Tryp::NoteConvertible
Float.send :include, Tryp::NoteConvertible
