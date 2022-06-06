module EasyJSON
  def self.configs
    @configs ||= {}
  end

  # Shorter, more readable config instantiation
  def self.config(path: nil, defaults: nil, frozen_values: nil, required_keys: nil)
    EasyJSON::Config.new(path: path, defaults: defaults, frozen_values: frozen_values, required_keys: required_keys)
  end

  class Config
    @sensitive_keys = %w(credentials Credentials password Password)
    attr_reader :path

    def [](key)
      @config = Hashly.deep_merge(@config, @frozen_values)
      @config[key]
    end

    def []=(key, value)
      @config[key] = value
    end

    def to_s
      "Config path: #{path}\nContent: #{JSON.pretty_generate @config}"
    end

    def to_h
      Hashly.deep_merge(@config, @frozen_values).to_h
    end

    # Add a hash of default keys and values to be merged over the current defaults (if any).
    # The json config can override these values.
    def add_defaults(new_defaults)
      @defaults = Hashly.deep_merge(@defaults, new_defaults)
    end

    # Add a hash of hard-coded keys and values to be merged over the current hard-coded values (if any).
    # The json config can NOT override these values.
    def freeze_values(new_frozen_values)
      @frozen_values = Hashly.deep_merge(@frozen_values, new_frozen_values)
    end

    def config_without_sensitive_or_hardcoded_keys
      non_sensitive_content = Hashly.deep_reject(@config) { |k, _v| @sensitive_keys.include?(k) }
      Hashly.deep_reject_by_hash(non_sensitive_content, @frozen_values)
    end

    def save
      ::File.write(path, config_without_sensitive_or_hardcoded_keys.to_json)
    end

    def add_required_keys(new_required_keys)
      @required_keys = Hashly.deep_merge(@required_keys, new_required_keys)
    end

    def add_sensitive_keys(new_sensitive_keys)
      new_sensitive_keys = [new_sensitive_keys] if new_sensitive_keys.is_a?(String) || new_sensitive_keys.is_a?(Symbol)
      @sensitive_keys = (@sensitive_keys + new_sensitive_keys).uniq
    end

    def clear_sensitive_keys
      @sensitive_keys = []
    end

    # override the new method to return existing class if it exists
    def self.new(path: nil, defaults: nil, frozen_values: nil, required_keys: nil)
      path = ::File.expand_path(path || 'config.json')
      instance = EasyJSON.configs[path] # return existing instance if one already exists for the path provided
      unless instance.nil?
        # add defaults and hard coded values provided to existing instance
        instance.add_defaults(defaults)
        instance.freeze_values(frozen_values)
        instance.add_required_keys(required_keys)
        instance.initialize_config
        return instance
      end
      EasyJSON.configs[path] = super(path, defaults, frozen_values, required_keys) # create new instance if none existed
    end

    # returns a hash containing the json config file values merged over the default values.
    def initialize_config
      @config ||= {}
      @config = Hashly.deep_merge(@config, @defaults)
      @config = Hashly.deep_merge(@config, @json_config)
      @config = Hashly.deep_merge(@config, @frozen_values)
      missing_required_keys = Hashly.deep_diff_by_key(@config, @required_keys)
      raise "The following keys are missing from #{path}: #{missing_required_keys}" unless missing_required_keys.empty?
      @config
    end

    private

    def initialize(path, defaults, frozen_values, required_keys)
      @path = path
      @defaults = defaults || {}
      @frozen_values = frozen_values || {}
      @required_keys = required_keys || {}
      ::File.write(path, "{\n}") unless ::File.exist?(path) # Add empty config if none exists
      @json_config = JSON.parse(::File.read(path))
      initialize_config
    end
  end
end
