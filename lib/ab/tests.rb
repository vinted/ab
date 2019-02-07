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
      @ab_tests = config['ab_tests'] || []
      @salt = config['salt']
      @bucket_count = config['bucket_count']
      @id = id
    end

    def all
      grouped_ab_tests.keys.map { |name| [name, assigned_test(name).variant(false)] }.to_h
    end

    def method_missing(name, *)
      assigned_test(name.to_s) || null_test
    end

    def respond_to_missing?(*)
      true
    end

    private

    def null_test
      @null_test ||= NullTest.new
    end

    def assigned_test(name)
      @assigned_tests ||= {}
      if grouped_ab_tests.key?(name)
        @assigned_tests[name] ||= begin
                                    test = Test.new(grouped_ab_tests[name], @salt, @bucket_count)
                                    AssignedTest.new(test, @id)
                                  end
      end
    end

    def grouped_ab_tests
      @grouped_ab_tests ||= @ab_tests.reduce({}) do |hash, test|
        hash[test['name']] = test
        hash
      end
    end
  end
end
