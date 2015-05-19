module Ab
  module MissingVariant
    def method_missing(meth, *args, &block)
      if variant_method?(meth)
        log_missing_variant(meth)
        false
      else
        super
      end
    end

    def respond_to_missing?(meth, *)
      variant_method?(meth) ? true : super
    end

    private

    def variant_method?(meth)
      meth.to_s.end_with?('?')
    end

    def log_missing_variant(meth)
      Ab.config.logger.debug("[AB_testing] Checking non-existing variant: #{meth}")
    end
  end
end
