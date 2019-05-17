module Eyowo
  class Transfer < APIResource
    # Transfers funds to a bank account.
    # * *Params*:
    # - +params+:: Hash containing required transaction parameters.
    # - +&block+:: Block to yield server response to.
    def credit_bank(params, &block)
      params = construct_params(params, APIOperations::BANK_TRANSFER)
      self.class.post("/users/transfers/bank", params, &block)
    end

    # Transfers funds to an Eyowo user.
    # * *Params*:
    # - +params+:: Hash containing required transaction parameters.
    # - +&block+:: Block to yield server response to.
    def credit_phone(params, &block)
      params = construct_params(params, APIOperations::MOBILE_TRANSFER)
      self.class.post("/users/transfers/phone", params, &block)
    end
  end
end