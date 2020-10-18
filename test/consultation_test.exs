defmodule Cielo.ConsultationTest do
  use ExUnit.Case
  import Mox

  alias Cielo.Consultation

  describe "bin/1" do
    test "successfully bin consultation" do
      expectation_tuple =
        {:ok,
         %{
           card_type: "Crédito",
           corporate_card: false,
           foreign_card: true,
           issuer: "Bradesco",
           issuer_code: "237",
           provider: "VISA",
           status: "00"
         }}

      Cielo.HTTPMock
      |> expect(:get, fn
        "1/cardBin/451278" ->
          expectation_tuple
      end)

      assert ^expectation_tuple = Consultation.bin("451278")
    end

    test "unsuccessfully bin consultation" do
      expectation_tuple =
        {:error, :bad_request,
         [
           %{
             code: 217,
             message:
               "Bin number must have only numbers and six or nine to nineteen characters length"
           }
         ]}

      Cielo.HTTPMock
      |> expect(:get, fn
        "1/cardBin/45127A" ->
          expectation_tuple
      end)

      assert ^expectation_tuple = Consultation.bin("45127A")
    end
  end

  describe "merchant_order/1" do
    test "successfully merchant_order consultation" do
      expectation_tuple =
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
         }}

      Cielo.HTTPMock
      |> expect(:get, fn
        "/1/sales?merchantOrderId=2014111703" ->
          expectation_tuple
      end)

      assert ^expectation_tuple = Cielo.Consultation.merchant_order("2014111703")
    end

    test "unsuccessfully merchant_order consultation" do
      expectation_tuple = {:error, :not_found}

      Cielo.HTTPMock
      |> expect(:get, fn
        "/1/sales?merchantOrderId=201411170A" ->
          expectation_tuple
      end)

      assert ^expectation_tuple = Cielo.Consultation.merchant_order("201411170A")
    end
  end

  describe "payment/1" do
    test "successfully payment consultation" do
      expectation_tuple =
        {:ok,
         %{
           customer: %{address: %{}, name: "Comprador crédito simples"},
           merchant_order_id: "2014111703",
           payment: %{
             amount: 15700,
             authenticate: false
           }
         }}

      Cielo.HTTPMock
      |> expect(:get, fn
        "/1/sales/37d2dcc6-6397-4d40-8066-2539397cfa8c" ->
          expectation_tuple
      end)

      assert ^expectation_tuple =
               Cielo.Consultation.payment("37d2dcc6-6397-4d40-8066-2539397cfa8c")
    end
  end

  describe "recurrent_payment/1" do
    test "successfully recurrent_payment consultation" do
      expectation_tuple =
        {:ok,
         %{
           customer: %{address: %{}, name: "Comprador crédito simples"},
           merchant_order_id: "2014111703",
           payment: %{
             amount: 15700,
             authenticate: false
           }
         }}

      Cielo.HTTPMock
      |> expect(:get, fn
        "/1/RecurrentPayment/37d2dcc6-6397-4d40-8066-2539397cfa8c" ->
          expectation_tuple
      end)

      assert ^expectation_tuple =
               Cielo.Consultation.recurrent_payment("37d2dcc6-6397-4d40-8066-2539397cfa8c")
    end
  end
end
