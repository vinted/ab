module Ab
  module MissingVariant
    def method_missing(meth, *args, &block)
      variant_method?(meth) ? false : super
    end

    def respond_to_missing?(meth, *)
      variant_method?(meth) ? true : super
    end

    private

    def variant_method?(meth)
      meth.to_s.end_with?('?')
    end
  end
end
