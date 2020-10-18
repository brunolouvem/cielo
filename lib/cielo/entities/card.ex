defmodule Cielo.Entities.CreditCard do
  use Cielo.Entities.Base

  embedded_schema do
    field(:brand, :string)
    field(:card_number, :string)
    field(:card_on_file, :map)
    field(:expiration_date, :string)
    field(:holder, :string)
    field(:security_code, :string)
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [
      :brand,
      :card_number,
      :card_on_file,
      :expiration_date,
      :holder,
      :security_code
    ])
    |> validate_required([:brand, :card_number, :expiration_date, :holder, :security_code])
  end
end

defmodule Cielo.Entities.DebitCard do
  use Cielo.Entities.Base

  embedded_schema do
    field(:brand, :string)
    field(:card_number, :string)
    field(:expiration_date, :string)
    field(:holder, :string)
    field(:security_code, :string)
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [:brand, :card_number, :expiration_date, :holder, :security_code])
    |> validate_required([:brand, :card_number, :expiration_date, :holder, :security_code])
  end
end
