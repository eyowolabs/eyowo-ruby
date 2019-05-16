module Eyowo
  class Balance < APIResource
    # Retrieves the balance of an Eyowo user.
    def self.retrieve(params, &block)
      params = construct_params(params, APIOperations::GET_BALANCE)
      self.class.get("/users/balance", params, &block)
    end
  end
end