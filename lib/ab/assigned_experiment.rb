module Ab
  class AssignedExperiment
    def initialize(experiment, id)
      @experiment, @id = experiment, id
      @experiment.variants.map(&:name).each do |name|
        define_singleton_method("#{name}?") { name == variant }
      end
    end

    def variant
      return unless part_of_experiment?
      return unless running?

      result = @experiment.variants.find { |v| v.accumulated_chance_weight > weight_id }
      result.name if result
    end

    private

    def part_of_experiment?
      @experiment.buckets == 'all' || @experiment.buckets.include?(bucket_id)
    end

    def bucket_id
      @bucket_id ||= digest(@experiment.salt + @id.to_s) % @experiment.bucket_count
    end

    def running?
      now = DateTime.now
      now.between?(@experiment.start_at, @experiment.end_at)
    end

    def weight_id
      @variant_digest ||= digest(@experiment.seed + @id.to_s) % positive_weight_sum
    end

    def positive_weight_sum
      @experiment.weight_sum > 0 ? @experiment.weight_sum : 1
    end

    def digest(string)
      Digest::SHA256.hexdigest(string).to_i(16)
    end
  end
end
