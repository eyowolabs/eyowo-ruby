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
  def self.validate_params(params, operation)
    RequestValidator.instance.validate_params(params, operation)
    build_headers!(params, operation)
  end

  private

  # Builds request headers for operation type.
  # * *Params*:
  # - +params+:: request parameters.
  # - +operation+:: operation type
  def self.build_headers!(params, operation)
    if APIOperations::WALLET_OPERATION.include?(operation)
      raise ArgumentError "Invalid wallet token #{params[:wallet_token]}" if params[:wallet_token].nil?

      token_hash = { 'X-App-Wallet-Access-Token' => params[:wallet_token]}

      if params[:headers]
        params[:headers].merge!(token_hash)
      else
        params[:headers] = token_hash
      end
    end
  end
end