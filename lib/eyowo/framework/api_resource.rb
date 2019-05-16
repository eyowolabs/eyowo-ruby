require 'json'

class APIResource
  include HTTParty
  base_uri Eyowo.api_base_url
  headers 'Content-Type' => 'application/json'
  headers 'X-App-Key' => Eyowo.api_key
  headers 'X-IV' => Eyowo.encryption_iv

  open_timeout Eyowo.open_timeout
  read_timeout Eyowo.read_timeout
  write_timeout Eyowo.write_timeout

  protected
  # Validates the parameters of a resource operation.
  # * *Params*:
  # - +params+:: parameters to be validated.
  # - +operation+:: type of operation occurring.
  def self.construct_params(params, operation)
    RequestValidator.instance.validate_params(params, operation)
    headers = build_headers(params, operation)
    encrypted_data = encrypt_data(params)
    { authData: encrypted_data, headers: headers }
  end

  private

  # Encrypts request parameters.
  # * *Params*:
  # - +params+:: parameters to be validated.
  # * *Returns*:
  # - [String] containing encrypted data.
  def self.encrypt_data(params)
    data = params.delete(:headers)
    encrypted_data = "#{Eyowo.cipher.update(JSON.generate(data))}#{Eyowo.cipher.final}"

    encrypted_data
  end

  # Builds request headers for operation type.
  # * *Params*:
  # - +params+:: request parameters.
  # - +operation+:: operation type
  # * *Returns*:
  # - [Hash] containing built request headers.
  def self.build_headers(params, operation)
    return params[:headers] unless APIOperations::WALLET_OPERATION.include?(operation)
    raise ArgumentError "Invalid wallet token #{params[:wallet_token]}" if params[:wallet_token].nil?

    result = {}
    token_hash = { 'X-App-Wallet-Access-Token' => params[:wallet_token]}

    if params[:headers]
      result = result.merge(params[:headers]).merge(token_hash)
      return result
    end
    params[:headers] = token_hash
    params[:headers]
  end
end