require 'spec_helper'
require 'ostruct'

module Ab
  describe AssignedTest do
    let(:assigned_test) { AssignedTest.new(test, id) }
    let(:test) do
      OpenStruct.new(name: name, start_at: start_at, end_at: end_at,
                     buckets: buckets, seed: 'cccc8888', variants: variants,
                     weight_sum: 2, salt: 'e131bfcfcab06c65d633d0266c7e62a4918', bucket_count: 1000)
    end
    let(:id) { 1 }
    let(:name) { 'feed' }
    let(:start_at) { DateTime.now.prev_year }
    let(:end_at) { DateTime.now.next_year }
    let(:buckets) { 1..1000 }
    let(:thousand_variants) { 1.upto(1000).map { |i| AssignedTest.new(test, i).variant } }

    context 'with non existent variant' do
      let(:variants) { [OpenStruct.new(name: 'enabled', accumulated_chance_weight: 2)] }
      let(:message) { '[AB_testing] Checking non-existing variant: disabled?' }

      before { Ab.config.logger.should_receive(:debug).with(message) }

      subject { assigned_test.disabled? }

      it { should be false }
    end

    describe '#variant' do
      subject { assigned_test.variant }

      context 'single variant' do
        let(:variants) { [OpenStruct.new(name: 'enabled', accumulated_chance_weight: accumulated_chance_weight)] }

        context 'that is turned off' do
          let(:accumulated_chance_weight) { 0 }
          it { should be_nil }
        end

        context 'that is turned on with 2' do
          let(:accumulated_chance_weight) { 2 }
          it { should == 'enabled' }
        end

        context 'that is turned on with 111' do
          let(:accumulated_chance_weight) { 111 }
          it { should == 'enabled' }
        end
      end

      context 'single variant with buckets' do
        let(:buckets) { (1..100) }
        let(:variants) { [OpenStruct.new(name: 'enabled', accumulated_chance_weight: 2)] }

        specify 'half the ids fall under one, other under other' do
          enabled = thousand_variants.select { |variant| variant == 'enabled' }
          enabled.count.should be_within(20).of(100)
        end
      end

      context 'test that has not started yet' do
        let(:start_at) { DateTime.now.next_year.to_s }
        let(:buckets) { [1, 2, 3] }
        let(:variants) { [OpenStruct.new(name: 'enabled', accumulated_chance_weight: 2)] }
        it { should be_nil }
      end

      context 'test that has already ended' do
        let(:end_at) { DateTime.now.prev_year.to_s }
        let(:buckets) { [1, 2, 3] }
        let(:variants) { [OpenStruct.new(name: 'enabled', accumulated_chance_weight: 2)] }
        it { should be_nil }
      end

      context 'two variants' do
        let(:name) { 'button' }
        let(:variants) do
          [
            OpenStruct.new(name: 'red', accumulated_chance_weight: 1),
            OpenStruct.new(name: 'blue', accumulated_chance_weight: 2)
          ]
        end

        specify 'half the ids fall under one, other under other' do
          reds = thousand_variants.select { |variant| variant == 'red' }
          blues = thousand_variants.select { |variant| variant == 'blue' }
          reds.count.should be_within(20).of(500)
          blues.count.should be_within(20).of(500)
        end
      end
    end
  end
end
