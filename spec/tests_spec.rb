require 'spec_helper'

module Ab
  describe Tests do
    describe '.new' do
      subject { Tests.new(config, id) }
      let(:id) { 1 }

      context 'empty config' do
        let(:config) { {} }

        specify 'has no public methods' do
          (subject.public_methods(false) - [:method_missing, :respond_to?, :all]).count.should == 0
        end

        specify 'does not raise if method is not existant' do
          expect{ subject.bla_bla_bla }.to_not raise_error
        end
      end

      context 'single experiment with single variant' do
        let(:config) {
          {
            'salt' => 'anything',
            'bucket_count' => 1000,
            'ab_tests' => [{
              'name' => 'feed',
              'buckets' => 'all',
              'variants' => [{ 'name' => 'enabled', 'chance_weight' => 1 }]
            }]
          }
        }
        its(:feed) { should be_kind_of AssignedTest }
        its(:all) { should == { 'feed' => 'enabled' } }
      end
    end
  end
end
