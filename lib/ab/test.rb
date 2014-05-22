module Ab
  class Test
    def initialize(config, id)
      @assigned_experiments ||= {}

      config.each do |experiment|
        name = experiment['name']
        define_singleton_method(name) do
          @assigned_experiments[name] ||= AssignedExperiment.new(experiment, id)
        end
      end
    end
  end
end
