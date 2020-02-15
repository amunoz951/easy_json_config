module EasyJSON
  def self.configs
    @configs ||= {}
  end

  # Shorter, more readable config instantiation
  def self.config(path: nil, defaults: nil)
    EasyJSON::Config.new(path: path, defaults: defaults)
  end

  class Config
    @sensitive_keys = %w(credentials Credentials password Password)
    attr_reader :path

    # Add a hash of default keys and values to be merged over the current defaults (if any).
    # The json config can override these values.
    def add_defaults(new_defaults)
      @defaults = EasyFormat.deep_merge(@defaults, new_defaults)
    end

    # returns a hash containing the json config file values merged over the default values.
    def values
      EasyFormat.deep_merge(@defaults, @json_config)
    end

    def values_without_sensitive_keys
      EasyFormat::Hash.deep_reject(values) { |k, _v| @sensitive_keys.include?(k) }
    end

    def save
      ::File.write(path, values_without_sensitive_keys.to_json)
    end

    def add_sensitive_keys(keys)
      keys = [keys] if keys.is_a?(String) || keys.is_a?(Symbol)
      @sensitive_keys = (@sensitive_keys + keys).uniq
    end

    def clear_sensitive_keys
      @sensitive_keys = []
    end

    # override the new method to return existing class if it exists
    def self.new(path: nil, defaults: nil)
      path = ::File.expand_path(path || 'config.json')
      instance = EasyJSON.configs[path] # return existing instance if one already exists for the path provided
      unless instance.nil?
        instance.add_defaults(defaults)
        return instance
      end
      EasyJSON.configs[path] = super(path, defaults)
    end

    private

    def initialize(path, defaults)
      @path = path
      @defaults = defaults
      ::File.write(path, "{\n}") unless ::File.exist?(path) # Add empty config if none exists
      @json_config = JSON.parse(::File.read(path))
    end
  end
end
