module Eyowo
  class Bills < APIResource
    # Used to create a bill.
    # * *Params*:
    # - +params+:: Request parameters.
    # - +&block+:: block to which to yield response to.
    def self.create(params,  &block)
      params = construct_params(params, APIOperations::CREATE_BILL)
      self.class.post("/users/payments/bills/vtu", params, &block)
    end
  end
end