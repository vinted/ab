require 'spec_helper'

module Ab
  describe Tests do
    let(:tests) { Tests.new(config, id) }
    let(:config) { {} }
    let(:id) { 1 }

    shared_context 'simple config with feed' do
      let(:config) do
        {
          'salt' => 'anything',
          'bucket_count' => 1000,
          'ab_tests' => [{
            'name' => 'feed',
            'buckets' => 'all',
            'variants' => [{ 'name' => 'enabled', 'chance_weight' => 1 }]
          }]
        }
      end
    end

    describe '#respond_to?' do
      subject { tests.respond_to?(method_name) }

      1.upto(10).each do |i|
        context "random method name of #{i} length" do
          let(:method_name) { SecureRandom.hex(i) }
          it { should be_true }
        end
      end
    end

    describe '#method_missing' do
      subject { tests.send(method_name) }

      1.upto(10).each do |i|
        context "random method name of #{i} length" do
          let(:method_name) { SecureRandom.hex(i) }
          it { should be_kind_of(NullTest) }
        end
      end
    end

    describe '#all' do
      include_context 'simple config with feed'
      subject { tests.all }
      it { should == { 'feed' => 'enabled' } }
    end

    describe '.new' do
      subject { tests }

      specify 'has no public methods' do
        (subject.public_methods(false) - [:method_missing, :respond_to?, :all]).count.should == 0
      end

      context 'single experiment with single variant' do
        include_context 'simple config with feed'
        its(:feed) { should be_kind_of AssignedTest }
      end
    end
  end
end
