require 'singleton'

class RequestValidator
  include Singleton

  # Validates parameters of any given API resource request.
  # * *Params*:
  # - +params+:: request parameters.
  # - +operation+:: resource operation.
  def validate_params(params, operation)
    unless params.is_a?(Hash)
      raise ArgumentError "params instance of type #{params.class} found where Hash is expected."
    end
    params = Hash[params.map{ |k, v| [k.to_sym, v]}]

    case operation
    when APIOperations::CREATE_BILL
      inspect_parameters([:mobile, :amount, :provider, :wallet_token], params)
    when APIOperations::MOBILE_TRANSFER
      inspect_parameters([:mobile, :amount, :wallet_token], params)
    when APIOperations::BANK_TRANSFER
      inspect_parameters([:amount, :account_name, :account_number, :bank_code, :wallet_token], params)
    when APIOperations::GET_BALANCE
      inspect_parameters([:mobile], params)
    else
      raise ArgumentError "Invalid operation type specified."
    end
  end

  private
  # Inspects the parameters within a parameter hash.
  # * *Params*:
  # - +keys+:: Array of keys to inspect. All keys must be valid symbols.
  # - +params+:: Required parameters.
  def inspect_parameters(keys, params)
    keys.each { |param| params.fetch(param, &:raise_parameter_error) }
  end

  # Raises an error upon absence of required parameter.
  # * *Params*:
  # - +parameter+:: Required parameter.
  def raise_parameter_error(param)
    raise ArgumentError "#{param} is required."
  end
end