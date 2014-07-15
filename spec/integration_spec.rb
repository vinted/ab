require 'spec_helper'
require 'json-schema'

describe 'ab' do
  path_to_schema = "#{File.dirname(__FILE__)}/../config.json"

  Dir.glob("#{File.dirname(__FILE__)}/examples/**").each do |name|
    context "#{name} example" do
      let(:input) { IO.read("#{name}/input.json") }
      let(:output) { JSON.parse(IO.read("#{name}/output.json")) }

      specify 'validates against schema' do
        result = JSON::Validator.validate(path_to_schema, input, version: :draft3)
        result.should be true
      end

      specify 'correctly assigns variants' do
        cases = []
        output['variants'].map { |variant, ids| ids.each { |id| cases << [id, variant] } }

        cases.each do |id, variant|
          tests = Ab::Tests.new(input, id)
          tests.send(output['test']).variant.to_s.should == variant
          tests.send(output['test']).send("#{variant}?").should be true unless variant.empty?
        end
      end
    end
  end
end
