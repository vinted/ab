class ExperimentConfig < Struct.new(:hash)
  def buckets
    hash['buckets']
  end

  def name
    hash['name']
  end

  def variants
    @variants ||= begin
      accumulated = 0
      hash['variants'].map do |variant_hash|
        VariantConfig.new(variant_hash, accumulated += variant_hash['chance_weight'] )
      end
    end
  end

  def seed
    hash['seed']
  end

  def start_at
    @start_at ||= DateTime.parse(hash['start_at'])
  end

  def end_at
    @end_at ||= DateTime.parse(hash['end_at'])
  end
end
