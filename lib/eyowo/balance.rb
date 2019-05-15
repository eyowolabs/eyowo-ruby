module Eyowo
  class Balance < APIResource
    # Retrieves the balance of an Eyowo user.
    def self.retrieve(&block)
      self.class.get("/users/balance", {}, block)
    end
  end
end