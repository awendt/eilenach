import logging
import os
import json
import datetime
from fints.client import FinTS3PinTanClient

def lambda_handler(event, context):

  logging.basicConfig(level=logging.ERROR)
  f = FinTS3PinTanClient(
      os.environ['BANKING_BLZ'],  # Your bank's BLZ
      os.environ['BANKING_USERNAME'],
      os.environ['BANKING_PIN'],
      os.environ['BANKING_ENDPOINT']
  )

  accounts = f.get_sepa_accounts()

  balancesAllAccounts = {}
  for account in accounts:
    # conversion to float is okay here because we're not going to do
    # floating point arithmetic with the values.
    balancesAllAccounts[account.iban] = float(f.get_balance(account).amount.amount)

  print(json.dumps({
    'event': "bookkeeper:balances:read",
    'balances': balancesAllAccounts,
    'created_at': datetime.datetime.utcnow().isoformat() + 'Z' # this is ridiculous but Python violates ISO 8601
  }))

  return None
