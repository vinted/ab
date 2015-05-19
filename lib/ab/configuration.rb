module Ab
  class << self
    attr_writer :config

    def config
      @config ||= Config.new
    end

    def configure
      @config ||= Config.new
      yield(@config)
    end
  end

  class Config
    attr_accessor :logger

    def initialize
      @logger = Logger.new(nil)
    end
  end
end
