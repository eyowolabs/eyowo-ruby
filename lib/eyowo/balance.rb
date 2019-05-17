require_relative 'framework/api_resource'
require_relative 'constants/api_operations'

module Eyowo
  class Balance < APIResource
    # Retrieves the balance of an Eyowo user.
    # * *Params*:
    # - +params+:: Request parameters.
    # - +&block+:: block to which to yield response to.
    def self.retrieve(params, &block)
      puts params
      puts "This is our base URL: ", Eyowo.api_base_url
      params = construct_params(params, APIOperations::GET_BALANCE)
      self.get("https://api.console.eyowo.com/v1/users/balance", params, &block)
    end
  end
end