require 'spec_helper'

describe Experiment do
  subject { Experiment.new(config, id) }
  let(:id) { 1 }

  describe '#variant' do
    context 'single experiment with single variant' do
      let(:config) {
        {
          'name' => 'feed',
          'buckets' => 'all',
          'variants' => [{ 'name' => 'enabled', 'chance_weight' => chance_weight }]
        }
      }

      context 'that is turned off' do
        let(:chance_weight) { 0 }
        its(:variant) { should be_nil }
      end

      context 'that is turned on with 1' do
        let(:chance_weight) { 1 }
        its(:variant) { should == 'enabled' }
      end

      context 'that is turned on with 111' do
        let(:chance_weight) { 111 }
        its(:variant) { should == 'enabled' }
      end
    end
  end
end
