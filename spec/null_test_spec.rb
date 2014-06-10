require 'spec_helper'

module Ab
  describe NullTest do
    subject { NullTest.new }

    its(:variant) { should == nil }

    specify 'does not raise for method ending in question mark' do
      expect{ subject.bla? }.to_not raise_error
    end

    specify 'raises for method not ending in question mark' do
      expect{ subject.bla }.to raise_error
    end
  end
end
