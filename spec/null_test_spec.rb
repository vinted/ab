require 'spec_helper'

module Ab
  describe NullTest do
    subject { NullTest.new }

    its(:variant) { should be_nil }
    its(:start_at) { should_not be_nil }
    its(:end_at) { should_not be_nil }

    specify 'does not raise for method ending in question mark' do
      lambda { subject.bla? }.should_not raise_error
    end

    specify 'raises for method not ending in question mark' do
      lambda { subject.bla }.should raise_error
    end
  end
end
