module Ab
  class Test < Struct.new(:hash, :salt, :bucket_count)
    def buckets
      hash['buckets']
    end

    def all_buckets?
      hash['all_buckets']
    end

    def name
      hash['name']
    end

    def variants
      @variants ||= begin
        accumulated = 0
        hash['variants'].map do |variant_hash|
          Variant.new(variant_hash, accumulated += variant_hash['chance_weight'])
        end
      end
    end

    def seed
      hash['seed']
    end

    def start_at
      @start_at ||= parse_time('start_at', 0)
    end

    def end_at
      @end_at ||= parse_time('end_at', 3000)
    end

    def weight_sum
      variants.map(&:chance_weight).inject(:+)
    end

    private

    def parse_time(name, default)
      value = hash[name]
      value.nil? ? DateTime.new(default) : DateTime.parse(value)
    end
  end
end
