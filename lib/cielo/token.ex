defmodule Cielo.Token do
  @moduledoc """
  This module centralize all calls about recurrent payments.
  """

  alias Cielo.{HTTP, Utils}
  alias Cielo.Entities.TokenizeCard

  @type http_response :: {:error, any} | {:error, any, any} | {:ok, any}

  @base_card_endpoint "card"
  @get_card_endpoint @base_card_endpoint <> "/:token"

  @doc """
  Create a card tokenized.

  ## Examples

      iex(1)> Cielo.Token.create_token(valid_params)
      {:ok,
        %{
          card_token: "c23df495-8bae-443d-b41d-07e53f75c071",
          links: %{
            href: "https://apiquerysandbox.cieloecommerce.cielo.com.br/1/card/c23df495-8bae-443d-b41d-07e53f75c071",
            method: "GET",
            rel: "self"
          }
        }}

      iex(2)> Cielo.Token.create_token(invalid_params)
      {:error, :bad_request,
          [%{code: 126, message: "Credit Card Expiration Date is invalid"}]}

  """
  @spec create_token(map) :: http_response
  def create_token(params) do
    %TokenizeCard{}
    |> TokenizeCard.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} ->
        @base_card_endpoint
        |> HTTP.post(params)

      error ->
        {:error, Utils.changeset_errors(error)}
    end
  end

  @doc """
  Get card detail from token.

  ## Examples

      iex(1)> Cielo.Token.get_card(token)
      {:ok,
        %{
          card_number: "************2057",
          expiration_date: "12/2028",
          holder: "Teste Holder"
        }}

      iex(2)> Cielo.Token.get_card(invalid_token)
      {:error, :bad_request, "Not found"}

  """
  @spec get_card(binary) :: http_response
  def get_card(token) do
    @get_card_endpoint
    |> Cielo.HTTP.build_path(":token", token)
    |> HTTP.get()
  end
end
