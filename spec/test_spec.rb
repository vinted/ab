require 'spec_helper'

module Ab
  describe Test do
    describe '.new' do
      subject { Test.new(config, id) }
      let(:id) { 1 }

      context 'empty config' do
        let(:config) { [] }
        specify 'has no public methods' do
          subject.public_methods(false).count.should == 0
        end
      end

      context 'single experiment with single variant' do
        let(:config) {
          [{
            'name' => 'feed',
            'variants' => [{ 'name' => 'enabled', 'chance_weight' => 1 }]
          }]
        }
        its(:feed) { should be_kind_of AssignedExperiment }
      end
    end
  end
end
