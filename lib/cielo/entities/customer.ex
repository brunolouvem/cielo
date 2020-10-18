defmodule Cielo.Entities.Customer do
  use Cielo.Entities.Base

  embedded_schema do
    field(:name, :string)
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:name])
  end
end

defmodule Cielo.Entities.BankSlipCustomer do
  use Cielo.Entities.Base

  embedded_schema do
    field(:name, :string)
    field(:identity, :string)

    embeds_one(:address, Cielo.Entities.CustomerAddress)
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:name, :identity])
    |> cast_embed(:address)
    |> validate_required([:address])
  end
end

defmodule Cielo.Entities.CustomerAddress do
  use Cielo.Entities.Base

  @required_fields [
    :street,
    :number,
    :complement,
    :zip_code,
    :district,
    :city,
    :state,
    :country
  ]

  embedded_schema do
    field(:street, :string)
    field(:number, :string)
    field(:complement, :string)
    field(:zip_code, :string)
    field(:district, :string)
    field(:city, :string)
    field(:state, :string)
    field(:country, :string)
  end

  def changeset(customer_address, attrs) do
    customer_address
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
