module Ab
  class AssignedTest
    include Ab::MissingVariant

    def initialize(test, id)
      @test = test
      @id = id
    end

    class << self
      attr_reader :before, :after
      def before_picking_variant(&block)
        @before = block
      end

      def after_picking_variant(&block)
        @after = block
      end
    end

    def method_missing(name, *args, &block)
      variant_query = name.to_s[0..-2]
      return variant == variant_query if variant_method?(name) && variants.include?(variant_query)
      super
    end

    def variant(run_callbacks = true)
      @variant ||= begin
        return unless part_of_test?
        return unless running?

        AssignedTest.before.call(name) if run_callbacks && AssignedTest.before.respond_to?(:call)
        picked_variant = @test.variants.find { |v| v.accumulated_chance_weight > weight_id }

        result = picked_variant.name if picked_variant
        AssignedTest.after.call(name, result) if run_callbacks && AssignedTest.after.respond_to?(:call)
        result
      end
    end

    def start_at
      @test.start_at
    end

    def end_at
      @test.end_at
    end

    def variants
      @test.variants.map(&:name)
    end

    private

    def name
      @test.name
    end

    def part_of_test?
      @test.all_buckets? ||
        @test.buckets && @test.buckets.include?(bucket_id)
    end

    def bucket_id
      @bucket_id ||= digest("#{@test.salt}#{@id}") % @test.bucket_count
    end

    def running?
      DateTime.now.between?(start_at, end_at)
    end

    def weight_id
      @variant_digest ||= digest("#{@test.seed}#{@id}") % positive_weight_sum
    end

    def positive_weight_sum
      @test.weight_sum > 0 ? @test.weight_sum : 1
    end

    def digest(string)
      Digest::SHA256.hexdigest(string).to_i(16)
    end
  end
end
