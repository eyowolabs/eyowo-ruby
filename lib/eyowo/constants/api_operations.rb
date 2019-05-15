module APIOperations
  # Bill resource operations.
  CREATE_BILL = :create_bill

  # Transfer resource operations.
  MOBILE_TRANSFER = :mobile_transfer
  BANK_TRANSFER = :bank_transfer

  WALLET_OPERATION = [CREATE_BILL, MOBILE_TRANSFER, BANK_TRANSFER]
end