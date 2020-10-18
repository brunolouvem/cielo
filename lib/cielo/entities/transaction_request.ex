defmodule Cielo.Entities.CreditTransactionRequest do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:merchant_order_id, :string)

    embeds_one(:customer, Entities.Customer)
    embeds_one(:payment, Entities.CreditCardPayment)
  end

  def changeset(credit_transaction_request, attrs) do
    credit_transaction_request
    |> cast(attrs, [:merchant_order_id])
    |> cast_embed(:customer)
    |> cast_embed(:payment)
    |> validate_required([:merchant_order_id, :customer, :payment])
  end
end

defmodule Cielo.Entities.DebitTransactionRequest do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:merchant_order_id, :string)

    embeds_one(:customer, Entities.Customer)
    embeds_one(:payment, Entities.DebitCardPayment)
  end

  def changeset(credit_transaction_request, attrs) do
    credit_transaction_request
    |> cast(attrs, [:merchant_order_id])
    |> cast_embed(:customer)
    |> cast_embed(:payment)
    |> validate_required([:merchant_order_id, :customer, :payment])
  end
end

defmodule Cielo.Entities.BankSlipTransactionRequest do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:merchant_order_id, :string)

    embeds_one(:customer, Entities.BankSlipCustomer)
    embeds_one(:payment, Entities.BankSlipPayment)
  end

  def changeset(bankslip_transaction_request, attrs) do
    bankslip_transaction_request
    |> cast(attrs, [:merchant_order_id])
    |> cast_embed(:customer)
    |> cast_embed(:payment)
    |> validate_required([:merchant_order_id, :customer, :payment])
  end
end

defmodule Cielo.Entities.RecurrentTransactionRequest do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:merchant_order_id, :string)

    embeds_one(:customer, Entities.Customer)
    embeds_one(:payment, Entities.RecurrentPayment)
  end

  def changeset(bankslip_transaction_request, attrs) do
    bankslip_transaction_request
    |> cast(attrs, [:merchant_order_id])
    |> cast_embed(:customer)
    |> cast_embed(:payment)
    |> validate_required([:merchant_order_id, :customer, :payment])
  end
end
