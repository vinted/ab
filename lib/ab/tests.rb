module Ab
  class Tests
    include Hooks
    define_hooks :before_picking_variant, :after_picking_variant

    Ab::AssignedTest.before_picking_variant do |test|
      Ab::Tests.run_hook :before_picking_variant, test
    end
    Ab::AssignedTest.after_picking_variant do |test, variant|
      Ab::Tests.run_hook :after_picking_variant, test, variant
    end

    def initialize(config, id)
      salt = config['salt']
      bucket_count = config['bucket_count']

      tests = (config['ab_tests'] || []).map { |test| Test.new(test, salt, bucket_count) }

      @assigned_tests = tests.map do |test|
        assigned_test = AssignedTest.new(test, id)
        define_singleton_method(test.name) { assigned_test }
        [test.name, assigned_test]
      end
    end

    def all
      Hash[@assigned_tests.map { |name, assigned_test| [name, assigned_test.variant] }]
    end

    def method_missing(meth, *args, &block)
      @null_test ||= NullTest.new
    end

    def respond_to?(meth)
      true
    end
  end
end
