class Experiment
  SALT = 'e131bfcfcab06c65d633d0266c7e62a4918' # should come from config root?
  BUCKET_COUNT = 1000 # should come from config root?

  def initialize(config, id)
    @config = ExperimentConfig.new(config)
    @id = id

    variants.map(&:name).each do |name|
      define_singleton_method("#{name}?") { name == variant }
    end
  end

  def variant
    return unless part_of_experiment?
    return unless running?

    result = variants.find { |v| v.accumulated_chance_weight > weight_id }
    result.name if result
  end

  private

  def part_of_experiment?
    @config.buckets == 'all' || @config.buckets.include?(bucket_id)
  end

  def running?
    now = DateTime.now
    now.between?(@config.start_at, @config.end_at)
  end

  def weight_id
    @variant_digest ||= digest(@config.seed + @id.to_s) % positive_weight_sum
  end

  def positive_weight_sum
    weight_sum > 0 ? weight_sum : 1
  end

  def weight_sum
    variants.map(&:chance_weight).inject(:+)
  end

  def bucket_id
    @bucket_id ||= digest(SALT + @id.to_s) % BUCKET_COUNT
  end

  def variants
    @config.variants
  end

  def digest(string)
    Digest::SHA256.hexdigest(string).to_i(16)
  end
end
