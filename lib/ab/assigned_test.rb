module Ab
  class AssignedTest
    include Hooks
    define_hooks :before_picking_variant, :after_picking_variant

    def initialize(test, id)
      @test, @id = test, id
      @test.variants.map(&:name).each do |name|
        define_singleton_method("#{name}?") { name == variant }
      end
    end

    def variant
      @variant ||= begin
        return if @id.nil?
        return unless part_of_test?
        return unless running?

        run_hook :before_picking_variant, @test.name
        picked_variant = @test.variants.find { |v| v.accumulated_chance_weight > weight_id }

        result = picked_variant.name if picked_variant
        run_hook :after_picking_variant, @test.name, result
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
