module Ab
  class Experiments
    include Hooks
    define_hooks :before_picking_variant, :after_picking_variant

    Ab::AssignedExperiment.before_picking_variant do |experiment|
      Ab::Experiments.run_hook :before_picking_variant, experiment
    end
    Ab::AssignedExperiment.after_picking_variant do |experiment, variant|
      Ab::Experiments.run_hook :after_picking_variant, experiment, variant
    end

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

    def method_missing(meth, *args, &block)
      @null_experiment ||= NullExperiment.new
    end

    def respond_to?(meth)
      true
    end
  end
end
