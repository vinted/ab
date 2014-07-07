module Ab
  class Tests
    class << self
      def before_picking_variant(&block)
        AssignedTest.before_picking_variant(&block)
      end

      def after_picking_variant(&block)
        AssignedTest.after_picking_variant(&block)
      end
    end

    def initialize(json, id)
      json ||= {}
      config = json.is_a?(Hash) ? json : JSON.parse(json)

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
