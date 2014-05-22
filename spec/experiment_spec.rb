require 'spec_helper'

describe Experiment do
  let(:experiment) { Experiment.new(config, id) }
  let(:config) {
    {
      'name' => name,
      'start_at' => start_at,
      'end_at' => end_at,
      'buckets' => buckets,
      'seed' => seed,
      'variants' => variants
    }
  }
  let(:id) { 1 }
  let(:name) { 'feed' }
  let(:start_at) { DateTime.now.prev_year.to_s }
  let(:end_at) { DateTime.now.next_year.to_s }
  let(:seed) { 'cccc8888' }
  let(:buckets) { 'all' }
  let(:thousand_variants) { 1.upto(1000).map { |i| Experiment.new(config, i).variant } }

  describe '#variant' do
    subject { experiment.variant }

    context 'single variant' do
      let(:variants) { [{ 'name' => 'enabled', 'chance_weight' => chance_weight }] }

      context 'that is turned off' do
        let(:chance_weight) { 0 }
        it { should be_nil }
      end

      context 'that is turned on with 1' do
        let(:chance_weight) { 1 }
        it { should == 'enabled' }
      end

      context 'that is turned on with 111' do
        let(:chance_weight) { 111 }
        it { should == 'enabled' }
      end
    end

    context 'single variant with buckets' do
      let(:buckets) { (1..100) }
      let(:variants) { [{ 'name' => 'enabled', 'chance_weight' => 1 }] }

      specify 'half the ids fall under one, other under other' do
        enabled = thousand_variants.select { |variant| variant == 'enabled' }
        enabled.count.should be_within(20).of(100)
      end
    end

    context 'experiment that has not started yet' do
      let(:start_at) { DateTime.now.next_year.to_s }
      let(:buckets) { [1, 2, 3] }
      let(:variants) { [{ 'name' => 'enabled', 'chance_weight' => 1 }] }
      it { should be_nil }
    end

    context 'experiment that has already ended' do
      let(:end_at) { DateTime.now.prev_year.to_s }
      let(:buckets) { [1, 2, 3] }
      let(:variants) { [{ 'name' => 'enabled', 'chance_weight' => 1 }] }
      it { should be_nil }
    end

    context 'two variants' do
      let(:name) { 'button' }
      let(:variants) {
        [
          { 'name' => 'red', 'chance_weight' => 1 },
          { 'name' => 'blue', 'chance_weight' => 1 }
        ]
      }

      specify 'half the ids fall under one, other under other' do
        reds = thousand_variants.select { |variant| variant == 'red' }
        blues = thousand_variants.select { |variant| variant == 'blue' }
        reds.count.should be_within(20).of(500)
        blues.count.should be_within(20).of(500)
      end
    end
  end
end
