defmodule Cielo.Consultation do
  @moduledoc ~S"""
  This module makes all consultations call in Cielo API

  ## Reference API:
  - [MerchantId Consultation](https://developercielo.github.io/manual/cielo-ecommerce#consulta-merchandorderid86)
  - [PaymentId Consultation](https://developercielo.github.io/manual/cielo-ecommerce#consulta-paymentid83)
  - [Recurrent Consultation](https://developercielo.github.io/manual/cielo-ecommerce#consulta-recorr%C3%AAncia)
  - [Bin Consultation](https://developercielo.github.io/manual/cielo-ecommerce#consulta-bin)
  """
  use Cielo.Application

  @bin_endpoint "1/cardBin/:card_digits"
  @payment_endpoint "/1/sales/:identifier"
  @merchant_endpoint "/1/sales?merchantOrderId=:identifier"
  @recurrent_payment_endpoint "/1/RecurrentPayment/:identifier"

  @doc """
  Wrap a consultation of a payment by `merchant_order_id`, if not found a payments with this merchant_order_id, an error tuple will be returned.

  The payload of response have a `:payment` key with valeu as a list, eg.:

  ## Examples

      iex> Cielo.Consultation.merchant_order("2014111703")
      {:ok,
      %{
      payments: [
        %{
          payment_id: "37d2dcc6-6397-4d40-8066-2539397cfa8c",
          receveid_date: "2020-10-02T20:46:22.033"
        },
        %{
          payment_id: "9b446419-32c3-4feb-aab4-54768767c1a0",
          receveid_date: "2020-10-04T15:14:04.93"
        }
      ]
      }

      iex> Cielo.Consultation.merchant_order("0000000000")
      {:error, :not_found}
  """
  @spec merchant_order(binary()) :: {:error, any, list()} | {:error, any} | {:ok, map}
  def merchant_order(merchant_order_id) do
    @merchant_endpoint
    |> Cielo.HTTP.build_path(":identifier", merchant_order_id)
    |> adapter().get()
  end

  @doc """
  Consult one payment by paymentID.

  ## Example

      iex> Cielo.Consultation.payment("37d2dcc6-6397-4d40-8066-2539397cfa8c")
      {:ok,
        %{
          customer: %{address: %{}, name: "Comprador crédito simples"},
          merchant_order_id: "2014111703",
          payment: %{
            amount: 15700,
            authenticate: false,
            ...
          }
        }
      }
  """
  @spec payment(binary()) :: {:error, any, list()} | {:error, any} | {:ok, map}
  def payment(identifier) do
    @payment_endpoint
    |> Cielo.HTTP.build_path(":identifier", identifier)
    |> adapter().get()
  end

  @doc """
  Consult one recurrent payment by paymentID.

  ## Example
      iex> Cielo.Consultation.recurrent_payment("8814cc0e-3658-42bc-8820-52b7439e668a")
      {:ok,
        %{
          customer: %{address: %{}, name: "Comprador crédito simples"},
          merchant_order_id: "2014111703",
          payment: %{
            amount: 15700,
            authenticate: false,
            ...
          }
        }
      }
  """
  @spec recurrent_payment(binary()) :: {:error, any, list()} | {:error, any} | {:ok, map}
  def recurrent_payment(recurrent_payment_id) do
    @recurrent_payment_endpoint
    |> Cielo.HTTP.build_path(":identifier", recurrent_payment_id)
    |> adapter().get()
  end

  @doc """
  Consult bin card for extra informations about card.

  ## Example

      iex> Cielo.Consultation.bin("538965")
      {:ok,
        %{
          card_type: "Débito",
          corporate_card: false,
          foreign_card: true,
          issuer: "Bradesco",
          issuer_code: "237",
          provider: "MASTERCARD",
          status: "00"
        }
      }
  """
  @spec bin(binary()) :: {:error, any, list()} | {:error, any} | {:ok, map}
  def bin(bin_card) do
    @bin_endpoint
    |> Cielo.HTTP.build_path(":card_digits", "#{bin_card}")
    |> adapter().get()
  end
end
