require 'openssl'

module Eyowo
  @api_version = 1
  @app_env = :production
  @api_base_url = nil

  @force_ssl = true
  @network_retry_delay = 0.5
  @max_network_retries = 2

  @open_timeout = 30
  @read_timeout = 80
  @write_timeout = 20

  @required_config_params = [:app_key, :app_secret]
  @permitted_environments = [:production, :sandbox]

  @encryption_iv = nil
  @cipher = OpenSSL::Cipher::AES256.new :CBC

  class << self
    attr_accessor :app_key, :app_secret, :encryption_iv, :api_version, :force_ssl,
                  :network_retry_delay, :max_network_retries, :app_env, :open_timeout,
                  :read_timeout, :write_timeout

    attr_reader :required_config_params, :api_base_url, :cipher
  end


  # Initializes API client with appropriate configuration options.
  # * *Params*:
  # - +params+:: [Hash] specifying required client options. The following params are required:
  #
  # -- app_key: The developer api key.
  # -- app_secret: Application secret.
  #
  # - +options+:: [Hash] specifying optional configurations. The available options are:
  #
  # -- api_version: Version of developer API.
  # -- force_ssl: true if an ssl connection should be forced by client false otherwise.
  # -- network_retry_delay: the amount of time in seconds to be pass before retrying a request.
  # -- max_network_retry: maximum number of times to retry a given request.
  # -- open_timeout: Time in seconds within which an HTTP connection must be established.
  # -- read_timeout: HTTP read timeout in seconds.
  # -- write_timeout: HTTP write timeout in seconds.
  # -- encryption_iv: A randomly generated 32 character long string used for a cryptographic IV.
  # -- app_env: Current app environment.
  def self.init(params, options = {})
    params = Hash[params.map { |k, v| [k.to_sym, v] }]
    sanitize_configurations(params)
    validate_configurations(params)

    params.each { |k, v| instance_variable_set("@#{k.to_s}", v) }
    options.each { |k, v| instance_variable_set("@#{k.to_s}", v) if instance_variable_defined?("@#{k.to_s}") }

    unless options[:app_env].nil? || @permitted_environments.include?(options[:app_env])
      raise ArgumentError.new "Invalid :app_env provided. Config must belong to: #{@permitted_environments}"
    end

    HTTParty::Basement.default_options.update(verify: false) unless @force_ssl
    @cipher.encrypt
    @cipher.key = @app_key

    if @encryption_iv.nil?
      @encryption_iv = @cipher.random_iv
    else
      raise ArgumentError.new "Invalid :encryption_iv" if @encryption_iv.length != 32

      @cipher.iv = @encryption_iv
    end

    resolve_app_env(options.has_key?(:app_env))
    resolve_base_url
  end

  private

  # Sanitizes client configurations.
  # * *Params*:
  # - +params+:: configuration parameters.
  def self.sanitize_configurations(params)
    params.delete_if { |k, _| !@required_config_params.include?(k) }
  end

  # Validates client configurations.
  # * *Params*:
  # - +params+:: configuration parameters.
  def self.validate_configurations(params)
    @required_config_params.each do |param|
      params.fetch(param) { |param_key|
        raise ArgumentError.new "#{param_key} is a required client configuration and must be specified."
      }
    end
  end

  # Resolves the application environment.
  def self.resolve_app_env(as_option_config = true)
    unless @permitted_environments.include?(@app_env)
      raise ArgumentError.new "Invalid app_env option specified. Permitted options: [:production, :sandbox]"
    end

    unless as_option_config
      env = ENV.fetch('APP_ENV', :production)

      return @app_env = env.to_sym if @permitted_environments.include?(env.to_sym)
      raise ArgumentError.new "Invalid app_env environment variable specified. Permitted options: [:production, :sandbox]"
    end
  end

  # Resolves server base url.
  def self.resolve_base_url
    @api_base_url = if @app_env == :production
                      "https://api.console.eyowo.com/v#{api_version}"
                    else
                      "https://api.sandbox.developer.eyowo.com/v#{api_version}"
                    end
  end
end

require_relative 'eyowo/version'
require_relative 'eyowo/balance'
require_relative 'eyowo/bill'
require_relative 'eyowo/transfer'