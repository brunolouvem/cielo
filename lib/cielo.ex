defmodule Cielo do
  @moduledoc """
  Main module of client
  """

  defdelegate bin_consult(bin_card), to: Cielo.Consultation, as: :bin
  defdelegate merchant_order_consult(merchant_order_id), to: Cielo.Consultation, as: :merchant_order
  defdelegate payment_consult(identifier), to: Cielo.Consultation, as: :payment
  defdelegate recurrent_payment_consult(recurrent_payment_id), to: Cielo.Consultation, as: :recurrent_payment
  defdelegate credit_transaction(recurrent_payment_id), to: Cielo.Transaction, as: :credit
  defdelegate debit_transaction(recurrent_payment_id), to: Cielo.Transaction, as: :debit
  defdelegate bankslip_transaction(recurrent_payment_id), to: Cielo.Transaction, as: :bankslip
  defdelegate recurrent_transaction(recurrent_payment_id), to: Cielo.Transaction, as: :recurrent
end
