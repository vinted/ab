require 'spec_helper'

module Ab
  describe Test do
    let(:test) { Test.new(test_hash, '4321', 100) }

    context '#buckets' do
      subject { test.buckets }
      let(:test_hash) { { 'buckets' => [1, 2, 3] } }
      it { should == [1, 2, 3] }
    end

    context '#name' do
      subject { test.name }
      let(:test_hash) { { 'name' => 'test' } }
      it { should == 'test' }
    end

    context '#weight_sum' do
      subject { test.weight_sum }
      let(:test_hash) do
        { 'variants' => [{ 'chance_weight' => 1 },
                         { 'chance_weight' => 2 }] }
      end
      it { should == 3 }
    end

    context '#start_at' do
      subject { test.start_at }

      context 'nil' do
        let(:test_hash) { {} }
        it { should < DateTime.new(1977) }
      end

      context 'april fools' do
        let(:test_hash) { { 'start_at' => '2014-04-01T12:00:00+00:00' } }
        it { should == DateTime.new(2014, 4, 1, 12) }
      end
    end

    context '#end_at' do
      subject { test.end_at }

      context 'nil' do
        let(:test_hash) { {} }
        it { should > DateTime.new(2020) }
      end

      context 'april fools' do
        let(:test_hash) { { 'end_at' => '2014-04-01T12:00:00+00:00' } }
        it { should == DateTime.new(2014, 4, 1, 12) }
      end
    end
  end
end
