module Ab
  class Test < Struct.new(:hash, :salt, :bucket_count)
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
          Variant.new(variant_hash, accumulated += variant_hash['chance_weight'] )
        end
      end
    end

    def seed
      hash['seed']
    end

    def start_at
      @start_at ||= hash['start_at'].nil? ? DateTime.new(0) : DateTime.parse(hash['start_at'])
    end

    def end_at
      @end_at ||= hash['end_at'].nil? ? DateTime.new(3000) : DateTime.parse(hash['end_at'])
    end

    def weight_sum
      variants.map(&:chance_weight).inject(:+)
    end
  end
end
