module Ab
  class Test < Struct.new(:hash, :salt, :bucket_count)
    DEFAULT_START_AT = DateTime.new(0)
    DEFAULT_END_AT = DateTime.new(3000)

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
      @start_at ||= parse_time('start_at', DEFAULT_START_AT)
    end

    def end_at
      @end_at ||= parse_time('end_at', DEFAULT_END_AT)
    end

    def weight_sum
      variants.map(&:chance_weight).inject(:+)
    end

    private

    def parse_time(name, default)
      value = hash[name]
      value.nil? ? default : DateTime.parse(value)
    end
  end
end
