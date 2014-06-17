module Ab
  class AssignedTest < Struct.new(:test, :id)
    include Hooks
    define_hooks :before_picking_variant, :after_picking_variant

    def variant
      @variant ||= begin
        return unless part_of_test?
        return unless running?

        run_hook :before_picking_variant, test.name
        picked_variant = test.variants.find { |v| v.accumulated_chance_weight > weight_id }

        result = picked_variant.name if picked_variant
        run_hook :after_picking_variant, test.name, result
        result
      end
    end

    def method_missing(meth, *args, &block)
      name = meth.to_s.chomp('?')
      test.variant_names.include?(name) ? variant == name : super
    end

    private

    def part_of_test?
      test.all_buckets? ||
        test.buckets && test.buckets.include?(bucket_id)
    end

    def bucket_id
      @bucket_id ||= digest("#{test.salt}#{id}") % test.bucket_count
    end

    def running?
      DateTime.now.between?(test.start_at, test.end_at)
    end

    def weight_id
      @variant_digest ||= digest("#{test.seed}#{id}") % positive_weight_sum
    end

    def positive_weight_sum
      test.weight_sum > 0 ? test.weight_sum : 1
    end

    def digest(string)
      Digest::SHA256.hexdigest(string).to_i(16)
    end
  end
end
