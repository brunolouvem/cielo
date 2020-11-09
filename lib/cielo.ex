defmodule Cielo do
  @moduledoc """
  Main module of client. This module wraps other specific modules and they main functions.

  Be aware that all modules implements parameter's validation for all calls in Cielo API, and
  these validations was written by Cielo employees, and the documentation can be found in
  [Cielo Dev Portal](https://developercielo.github.io/manual/cielo-ecommerce).
  """

  defdelegate bin_consult(bin_card), to: Cielo.Consultation, as: :bin

  defdelegate merchant_order_consult(merchant_order_id),
    to: Cielo.Consultation,
    as: :merchant_order

  defdelegate payment_consult(identifier), to: Cielo.Consultation, as: :payment

  defdelegate recurrent_payment_consult(recurrent_payment_id),
    to: Cielo.Consultation,
    as: :recurrent_payment
  defdelegate zero_auth_consult(params),
    to: Cielo.Consultation,
    as: :zero_auth

  defdelegate credit_transaction(params), to: Cielo.Transaction, as: :credit
  defdelegate debit_transaction(params), to: Cielo.Transaction, as: :debit
  defdelegate bankslip_transaction(params), to: Cielo.Transaction, as: :bankslip
  defdelegate recurrent_transaction(params), to: Cielo.Recurrency, as: :create_payment
  defdelegate capture(payment_id, params), to: Cielo.Transaction, as: :capture
  defdelegate capture(payment_id), to: Cielo.Transaction, as: :capture

  defdelegate deactivate_recurrent(recurrent_payment_id), to: Cielo.Recurrency, as: :deactivate
  defdelegate reactivate_recurrent(recurrent_payment_id), to: Cielo.Recurrency, as: :reactivate
  defdelegate update_recurrent(recurrent_payment_id, params), to: Cielo.Recurrency, as: :update_payment_data

  defdelegate create_token(params), to: Cielo.Token, as: :create_token
  defdelegate get_card(token), to: Cielo.Token, as: :get_card
end
