module Ab
  class AssignedTest
    def initialize(test, id)
      @test, @id = test, id
      @test.variants.map(&:name).each do |name|
        define_singleton_method("#{name}?") { name == variant }
      end
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

    def variant
      @variant ||= begin
        return unless part_of_test?
        return unless running?

        AssignedTest.before.call(@test.name) if AssignedTest.before.respond_to?(:call)
        picked_variant = @test.variants.find { |v| v.accumulated_chance_weight > weight_id }

        result = picked_variant.name if picked_variant
        AssignedTest.after.call(@test.name, result) if AssignedTest.after.respond_to?(:call)
        result
      end
    end

    def start_at
      @test.start_at
    end

    def end_at
      @test.end_at
    end

    private

    def part_of_test?
      @test.all_buckets? ||
        @test.buckets && @test.buckets.include?(bucket_id)
    end

    def bucket_id
      @bucket_id ||= digest("#{@test.salt}#{@id}") % @test.bucket_count
    end

    def running?
      DateTime.now.between?(@test.start_at, @test.end_at)
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
