require 'ab/version'
require 'ab/variant_config'
require 'ab/experiment_config'
require 'ab/experiment'

class Ab
  def initialize(config, id)
    @experiments ||= {}

    config.each do |experiment|
      name = experiment['name']
      define_singleton_method(name) do
        @experiments[name] ||= Experiment.new(experiment, id)
      end
    end
  end
end
