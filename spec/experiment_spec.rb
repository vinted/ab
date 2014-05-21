require 'spec_helper'

describe Experiment do
  let(:experiment) { Experiment.new(config, id) }
  let(:id) { 1 }

  describe '#variant' do
    subject { experiment.variant }

    context 'single variant' do
      let(:config) {
        {
          'name' => 'feed',
          'buckets' => 'all',
          'variants' => [{ 'name' => 'enabled', 'chance_weight' => chance_weight }]
        }
      }

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
      let(:config) {
        {
          'name' => 'feed',
          'buckets' => [1, 2, 3],
          'variants' => [{ 'name' => 'enabled', 'chance_weight' => 1 }]
        }
      }

      context 'id that is not part of experiment' do
        let(:id) { 1 }
        it { should == nil }
      end

      context 'id that is part of experiment' do
        let(:id) { 215 }
        it { should == 'enabled' }
      end
    end

    context 'two variants' do
      let(:config) {
        {
          'name' => 'button',
          'buckets' => 'all',
          'seed' => 'cccc8888',
          'variants' => [
            { 'name' => 'red', 'chance_weight' => 1 },
            { 'name' => 'blue', 'chance_weight' => 1 }
          ]
        }
      }
      it { should == 'red' }
    end
  end
end
