require 'spec_helper'

module Ab
  describe Experiment do
    let(:experiment) { Experiment.new(experiment_hash, '4321', 100) }

    context '#buckets' do
      subject { experiment.buckets }
      let(:experiment_hash) { { 'buckets' => [1, 2, 3] } }
      it { should == [1, 2, 3] }
    end

    context '#name' do
      subject { experiment.name }
      let(:experiment_hash) { { 'name' => 'test' } }
      it { should == 'test' }
    end

    context '#start_at' do
      subject { experiment.start_at }
      let(:experiment_hash) { { 'start_at' => '2014-05-27T11:56:25+03:00' } }
      it { should == DateTime.new(2014, 5, 27, 11, 56, 25, '+3') }
    end

    context '#end_at' do
      subject { experiment.end_at }

      context 'nil' do
        let(:experiment_hash) { {} }
        it { should > DateTime.new(2020) }
      end

      context 'april fools' do
        let(:experiment_hash) { { 'end_at' => '2014-04-01T12:00:00+00:00' } }
        it { should == DateTime.new(2014, 4, 1, 12) }
      end
    end
  end
end
