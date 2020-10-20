defmodule Cielo.Transaction do
  @moduledoc """
  This module makes a transactions calls for credit, debit, bankslips and recurrent payments.

  Cielo API reference:
   - [Credit](https://developercielo.github.io/manual/cielo-ecommerce#cart%C3%A3o-de-cr%C3%A9dito)
   - [Debit](https://developercielo.github.io/manual/cielo-ecommerce#cart%C3%A3o-de-d%C3%A9bito)
   - [BankSlip](https://developercielo.github.io/manual/cielo-ecommerce#boleto)
   - [Recurrent](https://developercielo.github.io/manual/cielo-ecommerce#recorr%C3%AAncia)

  """

  @endpoint "sales/"

  alias Cielo.{Utils, HTTP}

  alias Cielo.Entities.{
    BankSlipTransactionRequest,
    CreditTransactionRequest,
    DebitTransactionRequest,
    RecurrentTransactionRequest
  }

  @doc """
  Create a credit transaction if passed attributes satisfy a validation criteria

  ## Successfull transaction

      iex(1)> attrs = %{
        customer: %{name: "Comprador crédito simples"},
        merchant_order_id: "2014111703",
        payment: %{
          amount: 15700,
          credit_card: %{
            brand: "Visa",
            card_number: "1234123412341231",
            card_on_file: %{reason: "Unscheduled", usage: "Used"},
            expiration_date: "12/2030",
            holder: "Teste Holder",
            security_code: "123"
          },
          installments: 1,
          is_crypto_currency_negotiation: true,
          soft_descriptor: "123456789ABCD",
          type: "CreditCard"
        }
      }
      iex(2)> Cielo.Transaction.credit(attrs)
      {:ok,
      %{
        customer: %{name: "Comprador crédito simples"},
        merchant_order_id: "2014111703",
        payment: %{
          amount: 15700,
          authenticate: false,
          authorization_code: "437560",
          capture: false,
          country: "BRA",
          credit_card: ...
          links: [
            %{
              href: "https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/...",
              method: "GET",
              rel: "self"
            },
            %{
              href: "https://apisandbox.cieloecommerce.cielo.com.br/1/sales/.../capture",
              method: "PUT",
              rel: "capture"
            },
            %{
              href: "https://apisandbox.cieloecommerce.cielo.com.br/1/sales/.../void",
              method: "PUT",
              rel: "void"
            }
          ],
          payment_id: "26e5da86-d975-4e2f-aa25-862b5a43e9f4",
          ...
          type: "CreditCard"
        }
      }}

  ## Failed transaction

      iex(1)> attrs = %{
        customer: %{name: "Comprador crédito simples"},
        merchant_order_id: "2014111703",
        payment: %{
          amount: 15700,
          credit_card: %{
            brand: "Visa",
            card_number: "1234123412341231",
            card_on_file: %{reason: "Unscheduled", usage: "Used"},
            expiration_date: "12/2030",
            holder: "Teste Holder"
          },
          installments: 1,
          is_crypto_currency_negotiation: true,
          soft_descriptor: "123456789ABCD",
          type: "CreditCard"
        }
      }
      iex(2)> Cielo.Transaction.credit(attrs)
      {:error,
        %{
          errors: [
            payment: %{
              errors: [credit_card: %{errors: [security_code: "can't be blank"]}]
            }
          ]
        }}
  """
  @spec credit(map) :: {:ok, map()} | {:error, map(), list()} | {:error, any}
  def credit(params) do
    make_post_transaction(CreditTransactionRequest, params)
  end

  @doc """
  Create a debit transaction if passed attributes satisfy a validation criteria

  ## Successfull transaction

      iex(1)> attrs = %{
        customer: %{name: "Comprador Cartão de débito"},
        merchant_order_id: "2014121201",
        payment: %{
          amount: 15700,
          authenticate: true,
          debit_card: %{
            brand: "Visa",
            card_number: "4551870000000183",
            expiration_date: "12/2030",
            holder: "Teste Holder",
            security_code: "123"
          },
          is_crypto_currency_negotiation: true,
          return_url: "http://www.cielo.com.br",
          type: "DebitCard"
        }
      }
      iex(2)> Cielo.Transaction.debit(attrs)
      {:ok,
      %{
        customer: %{name: "Comprador Cartão de débito"},
        merchant_order_id: "2014121201",
        payment: %{
          amount: 15700,
          authenticate: true,
          authentication_url: "https://authenticationmocksandbox.cieloecommerce.cielo.com.br/CardAuthenticator/Receive/...",
          country: "BRA",
          currency: "BRL",
          debit_card: %{
            brand: "Visa",
            card_number: "455187******0183",
            expiration_date: "12/2030",
            holder: "Teste Holder",
            save_card: false
          },
          is_crypto_currency_negotiation: true,
          is_splitted: false,
          links: [
            %{
              href: "https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/...",
              method: "GET",
              rel: "self"
            }
          ],
          payment_id: "dde3931d-4dd4-4ab9-8d87-73cbfb1c513a",
          proof_of_sale: "430002",
          provider: "Simulado",
          received_date: "2020-10-18 17:53:42",
          recurrent: false,
          return_code: "1",
          return_url: "http://www.cielo.com.br",
          status: 0,
          tid: "1018055342725",
          type: "DebitCard"
        }
      }}

  ## Failed transaction

      iex(1)> attrs = %{
        customer: %{name: "Comprador crédito simples"},
        merchant_order_id: "2014111703",
        payment: %{
          amount: 15700,
          credit_card: %{
            brand: "Visa",
            card_number: "1234123412341231",
            card_on_file: %{reason: "Unscheduled", usage: "Used"},
            holder: "Teste Holder"
          },
          installments: 1,
          is_crypto_currency_negotiation: true,
          soft_descriptor: "123456789ABCD",
          type: "CreditCard"
        }
      }
      iex(2)> Cielo.Transaction.credit(attrs)
      {:error,
      %{
        errors: [
          payment: %{
            errors: [debit_card: %{errors: [expiration_date: "can't be blank"]}]
          }
        ]
      }}
  """
  @spec debit(map) :: {:ok, map()} | {:error, map(), list()} | {:error, any}
  def debit(params) do
    make_post_transaction(DebitTransactionRequest, params)
  end

  @doc """
  Create a bankslip transaction if passed attributes satisfy a validation criteria

  ## Successfull transaction
      iex(1)> attrs = %{
        customer: %{
          address: %{
            city: "Rio de Janeiro",
            complement: "Sala 934",
            country: "BRA",
            district: "Centro",
            number: "160",
            state: "RJ",
            street: "Avenida Marechal Câmara",
            zip_code: "22750012"
          },
          identity: "1234567890",
          name: "Comprador Teste Boleto"
        },
        merchant_order_id: "2014111706",
        payment: %{
          address: "Rua Teste",
          amount: 15700,
          assignor: "Empresa Teste",
          boleto_number: "123",
          demonstrative: "Desmonstrative Teste",
          expiration_date: "2020-12-31",
          identification: "11884926754",
          instructions: "Aceitar somente até a data de vencimento, após essa data juros de 1% dia.",
          provider: "INCLUIR PROVIDER",
          type: "Boleto"
        }
      }
      iex(2)> Cielo.Transaction.bankslip(attrs)
      {:ok,
        %{
          customer: %{
            address: %{
              city: "Rio de Janeiro",
              complement: "Sala 934",
              country: "BRA",
              district: "Centro",
              number: "160",
              state: "RJ",
              street: "Avenida Marechal Câmara",
              zip_code: "22750012"
            },
            identity: "1234567890",
            name: "Comprador Teste Boleto"
          },
          merchant_order_id: "2014111706",
          payment: %{
            address: "Rua Teste",
            amount: 15700,
            assignor: "Empresa Teste",
            bank: 0,
            bar_code_number: "00092848600000157009999250000000012399999990",
            boleto_number: "123-2",
            country: "BRA",
            currency: "BRL",
            demonstrative: "Desmonstrative Teste",
            digitable_line: "00099.99921 50000.000013 23999.999909 2 84860000015700",
            expiration_date: "2020-12-31",
            identification: "11884926754",
            instructions: "Aceitar somente até a data de vencimento, após essa data juros de 1% dia.",
            is_splitted: false,
            links: [
              %{
                href: "https://apiquerysandbox.cieloecommerce.cielo.com.br/1/sales/...",
                method: "GET",
                rel: "self"
              }
            ],
            payment_id: "8a946b9a-a9ab-4c16-bebb-0565d11b88f3",
            provider: "Simulado",
            received_date: "2020-10-18 18:18:29",
            status: 1,
            type: "Boleto",
            url: "https://transactionsandbox.pagador.com.br/post/pagador/reenvia.asp/..."
          }
        }}

  ## Warning
  Consult the [provider list](https://developercielo.github.io/manual/cielo-ecommerce#transa%C3%A7%C3%A3o-de-boletos) to check if your bank are integrated by cielo in this API
  """
  @spec bankslip(map) :: {:ok, map()} | {:error, map(), list()} | {:error, any}
  def bankslip(params) do
    make_post_transaction(BankSlipTransactionRequest, params)
  end

  @spec recurrent(map) :: {:ok, map()} | {:error, map(), list()} | {:error, any}
  def recurrent(params) do
    make_post_transaction(RecurrentTransactionRequest, params)
  end

  @doc false
  def make_post_transaction(module, params, endpoint \\ @endpoint) do
    module
    |> struct()
    |> module.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} ->
        HTTP.post(endpoint, params)

      error ->
        {:error, Utils.changeset_errors(error)}
    end
  end
end
