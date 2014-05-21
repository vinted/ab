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
      let(:buckets) { [1, 2, 3] }
      let(:variants) { [{ 'name' => 'enabled', 'chance_weight' => 1 }] }

      context 'id that is not part of experiment' do
        let(:id) { 1 }
        it { should == nil }
      end

      context 'id that is part of experiment' do
        let(:id) { 215 }
        it { should == 'enabled' }
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
      it { should == 'red' }
    end
  end
end
