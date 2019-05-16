require 'openssl'

require 'eyowo/version'
require 'eyowo/balance'
require 'eyowo/bill'
require 'eyowo/transfer'

module Eyowo
  @api_version = 1
  @app_env = 'production'
  @api_base_url = nil

  @force_ssl = true
  @network_retry_delay = 0.5
  @max_network_retries = 2

  @open_timeout = 30
  @read_timeout = 80
  @write_timeout = 20

  @required_config_params = [:app_key, :encryption_iv]
  @permitted_environments = [:production, :development, :test]

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
  # -- wallet_token: Eyowo user wallet access token.
  # -- encryption_iv: A randomly generated 32 character long string used for a cryptographic IV.
  #
  # - +options+:: [Hash] specifying optional configuration options. The available options are:
  #
  # -- api_version: Version of developer API.
  # -- force_ssl: true if an ssl connection should be forced by client false otherwise.
  # -- network_retry_delay: the amount of time in seconds to be pass before retrying a request.
  # -- max_network_retry: maximum number of times to retry a given request.
  # -- open_timeout: Time in seconds within which an HTTP connection must be established.
  # -- read_timeout: HTTP read timeout in seconds.
  # -- write_timeout: HTTP write timeout in seconds.
  def self.init(params, options = {})
    params = Hash[params.map { |k, v| [k.to_sym, v] }]
    sanitize_configurations(params)
    validate_configurations(params)

    params.each { |k, v| instance_variable_set(k.to_s, v) }
    options.each { |k, v| instance_variable_set(k.to_s, v) if instance_variable_defined?(k.to_s) }

    unless options[:app_env].nil? || @permitted_environments.include?(options[:app_env])
      raise ArgumentError "Invalid :app_env provided. Config must belong to: #{@permitted_environments}"
    end

    HTTParty::Basement.default_options.update(verify: false) unless @force_ssl

    @cipher.key = @app_key
    @encryption_iv = @cipher.random_iv if @encryption_iv.nil?

    resolve_env
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
        raise ArgumentError "#{param_key} is a required client configuration and must be specified."
      }
    end
  end

  # Resolves the application environment.
  def self.resolve_env
    env = ENV.fetch('APP_ENV')

    @app_env = env.to_sym if @permitted_environments.include?(env.to_sym)
  end

  # Resolves server base url.
  def self.resolve_base_url
    @api_base_url = if app_env == 'production'
                      "https://developer.api.eyowo.com/#{api_version}"
                    else
                      "https://sandbox.api.eyowo.com/#{api_version}"
                    end
  end
end
