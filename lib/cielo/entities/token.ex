defmodule Cielo.Entities.TokenizeCard do
  use Cielo.Entities.Base

  embedded_schema do
    field(:customer_name, :string)
    field(:card_number, :string)
    field(:expiration_date, :string)
    field(:holder, :string)
    field(:brand, :string)
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [
      :brand,
      :card_number,
      :customer_name,
      :expiration_date,
      :holder
    ])
    |> validate_required([:brand, :card_number, :customer_name, :expiration_date, :holder])
  end
end
