module Ab
  class NullTest
    include Ab::MissingVariant

    def variant
    end

    def start_at
      Test::DEFAULT_START_AT
    end

    def end_at
      Test::DEFAULT_END_AT
    end
  end
end
