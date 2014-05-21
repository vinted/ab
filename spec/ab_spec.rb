require 'spec_helper'

describe Ab do
  describe '.new' do
    subject { ab.public_methods(false).count }
    let(:ab) { Ab.new(config, id) }
    let(:id) { 1 }

    context 'empty config' do
      let(:config) { {} }
      it { should == 0 }
    end
  end
end
