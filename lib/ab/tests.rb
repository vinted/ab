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
      @assigned_tests ||= {}

      (config['ab_tests'] || []).each do |test|
        name = test['name']
        @assigned_tests[name] = nil
        define_singleton_method(name) do
          test = Test.new(test, config['salt'], config['bucket_count'])
          @assigned_tests[name] ||= AssignedTest.new(test, id)
        end
      end
    end

    def all
      result = @assigned_tests.keys.map do |name|
        [name, send(name).variant]
      end
      Hash[result]
    end

    def method_missing(meth, *args, &block)
      @null_test ||= NullTest.new
    end

    def respond_to?(meth)
      true
    end
  end
end
