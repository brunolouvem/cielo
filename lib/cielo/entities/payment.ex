defmodule Cielo.Entities.CreditCardPayment do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:amount, :integer)
    field(:installments, :integer)
    field(:is_crypto_currency_negotiation, :boolean)
    field(:soft_descriptor, :string)
    field(:type, :string)

    embeds_one(:credit_card, Entities.CreditCard)
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :amount,
      :installments,
      :is_crypto_currency_negotiation,
      :soft_descriptor,
      :type
    ])
    |> cast_embed(:credit_card)
    |> validate_required([:amount, :installments, :credit_card, :type])
  end
end


defmodule Cielo.Entities.RecurrentPaymentUpdate do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:amount, :integer)
    field(:installments, :integer)
    field(:recurrent, :boolean)
    field(:soft_descriptor, :string)
    field(:currency, :string)
    field(:country, :string)
    field(:type, :string)

    embeds_one(:credit_card, Entities.CreditCardWithoutCVV)
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :amount,
      :installments,
      :recurrent,
      :soft_descriptor,
      :currency,
      :country,
      :type
    ])
    |> cast_embed(:credit_card)
    |> validate_required([:amount, :installments, :credit_card, :type])
  end
end

defmodule Cielo.Entities.RecurrentPayment do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:amount, :integer)
    field(:installments, :integer)
    field(:soft_descriptor, :string)
    field(:currency, :string)
    field(:type, :string)

    embeds_one(:recurrent_payment, Entities.Recurrent)
    embeds_one(:credit_card, Entities.CreditCard)
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :amount,
      :installments,
      :soft_descriptor,
      :type
    ])
    |> cast_embed(:recurrent_payment)
    |> cast_embed(:credit_card)
    |> validate_required([:amount, :installments, :credit_card, :recurrent_payment, :type])
  end
end

defmodule Cielo.Entities.Recurrent do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:authorize_now, :boolean)
    field(:end_date, :string)
    field(:start_date, :string)
    field(:interval, :string)
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:authorize_now, :end_date, :start_date, :interval])
    |> validate_required([:authorize_now])
    |> maybe_validate_interval()
  end

  def maybe_validate_interval(%Ecto.Changeset{changes: %{interval: _interval}} = changeset) do
    validate_inclusion(changeset, :interval, [
      "Monthly",
      "Bimonthly",
      "Quarterly",
      "SemiAnnual",
      "Annual"
    ])
  end

  def maybe_validate_interval(%Ecto.Changeset{changes: _changes} = changeset),
    do: changeset
end

defmodule Cielo.Entities.DebitCardPayment do
  use Cielo.Entities.Base
  alias Cielo.Entities

  embedded_schema do
    field(:amount, :integer)
    field(:authenticate, :boolean)
    field(:is_crypto_currency_negotiation, :boolean)
    field(:return_url, :string)
    field(:type, :string)

    embeds_one(:debit_card, Entities.DebitCard)
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :authenticate, :is_crypto_currency_negotiation, :return_url, :type])
    |> cast_embed(:debit_card)
    |> validate_required([:amount, :authenticate, :return_url, :debit_card, :type])
  end
end

defmodule Cielo.Entities.BankSlipPayment do
  use Cielo.Entities.Base

  embedded_schema do
    field(:amount, :integer)
    field(:provider, :string)
    field(:address, :string)
    field(:boleto_number, :string)
    field(:assignor, :string)
    field(:demonstrative, :string)
    field(:expiration_date, :string)
    field(:identification, :string)
    field(:instruction, :string)
    field(:type, :string)
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :amount,
      :provider,
      :address,
      :boleto_number,
      :assignor,
      :demonstrative,
      :expiration_date,
      :identification,
      :instruction,
      :type
    ])
    |> validate_required([:amount, :provider, :type])
  end
end
