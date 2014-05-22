module Ab
  class Test
    def initialize(config, id)
      @assigned_experiments ||= {}

      (config['ab_tests'] || []).each do |experiment|
        name = experiment['name']
        define_singleton_method(name) do
          experiment = Experiment.new(experiment, config['salt'], config['bucket_count'])
          @assigned_experiments[name] ||= AssignedExperiment.new(experiment, id)
        end
      end
    end
  end
end
