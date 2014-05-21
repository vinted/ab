class ExperimentConfig < Struct.new(:hash)
  def buckets
    hash['buckets']
  end

  def name
    hash['name']
  end

  def variants
    hash['variants']
  end

  def start_at
    @start_at ||= DateTime.parse(hash['start_at'])
  end

  def end_at
    @end_at ||= DateTime.parse(hash['end_at'])
  end
end
