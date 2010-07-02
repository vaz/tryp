require 'tryp/note'

module Tryp
  describe Note do
    def n i
      Note.new i
    end

    it "should be comparable" do
      n(20).should == n(20)
      n(20).should_not == n(40)
      n(50).should > n(30)
      n(20).should < n(60)
      n(20).should == 20
    end

    it "should convert strings to midi note values" do
      n('C4').value.should == 60
      n('D4').value.should == 62
      n('C#4').value.should == 61
    end

    it "should convert symbols to midi note values" do
      n(:C4).should == n('C4')
    end
    
    it "should convert floats (frequencies) to midi note values" do
      n(440.0).should == n('A4')
      n(110.0).should == n('A2')
    end

    it "should let the note name be case-insensitive" do
      n('C4')
    end

    it "should be raised or lowered one by accidentals" do
      n('C#4').value.should == 61
      n('Cb4').value.should == 59
      n('Csharp4').should == n('C#4')
      n('Cflat4').should == n('Cb4')
      n('Cflat4').should == n('B3')
    end

    it "should allow basic arithmetic" do
      (n('C4') + 1).should == n('C#4')
      (n('C4') - 1).should == n('B3')
      (n('C4') * 2).should == n('C5')
      (n('C4') / 2).should == n('C3')
    end

    it "should be able to sharpen or flatten" do
      n('C4').flatten.should == n('B3')
      n('C4').sharpen.should == n('C#4')
      note = n('C4')
      note.sharpen!
      note.should == n('C#4')
      note = n('C4')
      note.flatten!
      note.should == n('B3')
      n('C4').sharpen!.should == n('C4').sharpen
      n('C4').flatten!.should == n('C4').flatten
    end

    it "should be able to convert into the types it can convert from" do
      n('Ab4').to_s.should == 'G#4'
      n(:Gsharp3).to_sym.should == :"G#3"
      n(440.0).to_f.should == 440.0
      n(45).to_i.should == 45
    end

  end
end

