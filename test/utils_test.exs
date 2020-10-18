defmodule Cielo.UtilsTest do
  use ExUnit.Case

  alias Cielo.Entities.CreditCard
  alias Cielo.Entities.CreditTransactionRequest
  alias Cielo.Utils

  test "get_env/2 with system tuple" do
    System.put_env("test_key", "true")
    Utils.put_env(:test_key, {:system, "test_key"})
    assert Utils.get_env(:test_key, {:system, "test_key"}) == "true"
  end

  test "get_env/2 with default" do
    assert Utils.get_env(:some_key, true) == true
  end

  test "get_env/2 without default" do
    assert_raise Cielo.ConfigurationError, "missing config for :undefined_key", fn ->
      Utils.get_env(:undefined_key) == true
    end
  end

  test "changeset_errors/1" do
    changeset = %CreditCard{} |> CreditCard.changeset(%{holder: "Jonh Doe"})

    assert %{
             errors: [
               security_code: "can't be blank",
               expiration_date: "can't be blank",
               card_number: "can't be blank",
               brand: "can't be blank"
             ]
           } = Utils.changeset_errors(changeset)
  end

  test "changeset_errors/1 with error in child changeset" do
    changeset =
      %CreditTransactionRequest{}
      |> CreditTransactionRequest.changeset(%{
        merchant_order_id: "some_id",
        customer: %{name: "Jonh Doe"},
        payment: %{}
      })

    assert %{errors: [payment: %{errors: [type: "can't be blank", credit_card: "can't be blank", installments: "can't be blank", amount: "can't be blank"]}]} = Utils.changeset_errors(changeset)
  end

  test "map_from_cielo/1" do
    cielo_map = %{
      "Customer" => %{"Name" => "Bruno Louvem", "CustomerId" => 123_456},
      "Links" => [%{"Url" => "localhost"}]
    }

    assert %{
             customer: %{name: "Bruno Louvem", customer_id: 123_456},
             links: [%{url: "localhost"}]
           } == Utils.map_from_cielo(cielo_map)
  end

  test "map_to_cielo/1" do
    map = %{customer: %{name: "Bruno Louvem", customer_id: 123_456}, links: [%{url: "localhost"}]}

    assert %{
             "Customer" => %{"Name" => "Bruno Louvem", "CustomerId" => 123_456},
             "Links" => [%{"Url" => "localhost"}]
           } == Utils.map_to_cielo(map)
  end

  test "map_from_cielo/1 with converted map" do
    map = %{customer: %{name: "Bruno Louvem", customer_id: 123_456}, links: [%{url: "localhost"}]}

    assert %{
             customer: %{name: "Bruno Louvem", customer_id: 123_456},
             links: [%{url: "localhost"}]
           } == Utils.map_from_cielo(map)
  end

  test "map_to_cielo/1 with converted map" do
    map = %{
      "Customer" => %{"Name" => "Bruno Louvem", "CustomerId" => 123_456},
      "Links" => [%{"Url" => "localhost"}]
    }

    assert %{
             "Customer" => %{"Name" => "Bruno Louvem", "CustomerId" => 123_456},
             "Links" => [%{"Url" => "localhost"}]
           } == Utils.map_to_cielo(map)
  end
end
