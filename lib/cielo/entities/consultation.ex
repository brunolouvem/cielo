defmodule Cielo.Entities.ZeroAuthCardTokenConsutation do
  use Cielo.Entities.Base

  embedded_schema do
    field(:brand, :string)
    field(:card_token, :string)
    field(:save_card, :boolean)
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [
      :brand,
      :card_token,
      :save_card
    ])
    |> validate_required([:card_token, :save_card])
  end
end

defmodule Cielo.Entities.ZeroAuthCardConsutation do
  use Cielo.Entities.Base

  embedded_schema do
    field(:brand, :string)
    field(:card_number, :string)
    field(:card_on_file, :map)
    field(:expiration_date, :string)
    field(:holder, :string)
    field(:save_card, :boolean)
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
      :save_card,
      :security_code
    ])
    |> validate_required([
      :brand,
      :card_number,
      :expiration_date,
      :holder,
      :save_card,
      :security_code
    ])
  end
end
