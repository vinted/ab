class Experiment
  def initialize(experiment_config, id)
    @experiment_config = experiment_config

    variants.each do |variant|
      name = variant['name']
      define_singleton_method("#{name}?") { name == variant }
    end
  end

  def variant
    result = variants.find { |variant| variant['chance_weight'] > 0 }
    result['name'] if result
  end

  private

  def variants
    @experiment_config['variants']
  end

  def start_at
    @start_at ||= DateTime.parse(@experiment_config['start_at'])
  end

  def end_at
    @end_at ||= DateTime.parse(@experiment_config['end_at'])
  end
end
