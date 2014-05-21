class Experiment
  SALT = 'e131bfcfcab06c65d633d0266c7e62a4918' # should come from config root?
  BUCKET_COUNT = 1000 # should come from config root?

  def initialize(config, id)
    @config = ExperimentConfig.new(config)
    @id = id

    @config.variants.each do |variant|
      name = variant['name']
      define_singleton_method("#{name}?") { name == variant }
    end
  end

  def variant
    return unless part_of_experiment?

    result = @config.variants.find { |variant| variant['chance_weight'] > 0 }
    result['name'] if result
  end

  private

  def part_of_experiment?
    @config.buckets == 'all' || @config.buckets.include?(digest % BUCKET_COUNT)
  end

  def digest
    @digest ||= Digest::SHA256.hexdigest(salted_id).to_i(16)
  end

  def salted_id
    SALT + @id.to_s
  end
end
