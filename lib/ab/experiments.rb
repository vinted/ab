module Ab
  class Experiments
    include Hooks
    define_hooks :before_picking_variant, :after_picking_variant

    def initialize(config, id)
      @assigned_experiments ||= {}

      AssignedExperiment.before_picking_variant { run_hook :before_picking_variant }
      AssignedExperiment.after_picking_variant { run_hook :after_picking_variant }

      (config['ab_tests'] || []).each do |experiment|
        name = experiment['name']
        define_singleton_method(name) do
          experiment = Experiment.new(experiment, config['salt'], config['bucket_count'])
          @assigned_experiments[name] ||= AssignedExperiment.new(experiment, id)
        end
      end
    end

    def method_missing(meth, *args, &block)
      @null_experiment ||= NullExperiment.new
    end

    def respond_to?(meth)
      true
    end
  end
end
