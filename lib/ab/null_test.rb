module Ab
  class NullTest
    def variant
    end

    def start_at
      Test::DEFAULT_START_AT
    end

    def end_at
      Test::DEFAULT_END_AT
    end


    def method_missing(meth, *args, &block)
      meth.to_s.end_with?('?') ? false : super
    end

    def respond_to?(meth)
      meth.to_s.end_with?('?') ? true : super
    end
  end
end
