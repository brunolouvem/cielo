defmodule Cielo.Recurrency do
  @moduledoc """
  This module centralize all calls about recurrent payments.
  """

  alias Cielo.{HTTP, Utils}
  alias Cielo.Entities.{RecurrentTransactionRequest, RecurrentPaymentUpdate}

  @type http_response :: {:error, any} | {:error, any, any} | {:ok, any}

  @base_recurrent_url "RecurrentPayment/:payment_id"
  @update_enddate_endpoint @base_recurrent_url <> "/EndDate"
  @update_interval_endpoint @base_recurrent_url <> "/Interval"
  @update_charge_day_endpoint @base_recurrent_url <> "/RecurrencyDay"
  @update_amount_endpoint @base_recurrent_url <> "/Amount"
  @update_next_charge_date_endpoint @base_recurrent_url <> "/NextPaymentDate"
  @update_payment_endpoint @base_recurrent_url <> "/Payment"
  @deactivate_endpoint @base_recurrent_url <> "/Reactivate"
  @reactivate_endpoint @base_recurrent_url <> "/Deactivate"

  @valid_intervals ~w(monthly bimonthly quarterly semi_annual annual)a

  @doc """
  Create a recurrent payment data.

  ## Examples

      iex(1)> Cielo.Recurrency.update_end_date(valid_params)
      {:ok, success_map}

      iex(2)> Cielo.Recurrency.update_end_date(invalid_params)
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(2)> Cielo.Recurrency.update_end_date(invalid_params)
      {:error, %{
        errors: [...]
      }}

  """
  @spec create_payment(map) :: http_response
  def create_payment(params) do
    %RecurrentTransactionRequest{}
    |> RecurrentTransactionRequest.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} ->
        "sales/"
        |> HTTP.post(params)

      error ->
        {:error, Utils.changeset_errors(error)}
    end
  end

  @doc """
  Update a recurrent payment data.

  Caveats: This changing affects all data of payment json key.
  Thus, for mantaining previous data, you must inform the fields that will not be changed with the same saved values.
  For more information read the official documentation [here](https://developercielo.github.io/manual/cielo-ecommerce#modificando-dados-do-pagamento-da-recorr%C3%AAncia)

  ## Examples

      iex(1)> Cielo.Recurrency.update_end_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", %{...})
      {:ok, :updated}

      iex(2)> Cielo.Recurrency.update_end_date("26e5da86-d975-4e2f-aa25-862b5a44e8f6", %{...})
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(3)> Cielo.Recurrency.update_end_date("862b5a43e9f4", %{...})
      {:ok, :invalid_guid}
  """
  @spec update_payment_data(binary, map) :: http_response
  def update_payment_data(recurrent_payment_id, params) do
    %RecurrentPaymentUpdate{}
    |> RecurrentPaymentUpdate.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} ->
        @update_payment_endpoint
        |> HTTP.build_path(":payment_id", "#{recurrent_payment_id}")
        |> HTTP.put(params)
        |> Utils.format_update_response()

      error ->
        {:error, Utils.changeset_errors(error)}
    end
  end


  @doc """
  Update a recurrent payment end date.

  The date informed needs be ISO8601 format.

  ## Examples

      iex(1)> Cielo.Recurrency.update_end_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", "2020-12-12")
      {:ok, :updated}

      iex(2)> Cielo.Recurrency.update_end_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", ~D[2020-12-12])
      {:ok, :updated}

      iex(3)> Cielo.Recurrency.update_end_date("26e5da86-d975-4e2f-aa25-862b5a44e8f6", 2)
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(4)> Cielo.Recurrency.update_end_date("862b5a43e9f4", 15)
      {:ok, :invalid_guid}

      iex(5)> Cielo.Recurrency.update_end_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", -15)
      {:ok, :invalid_parameters}

      iex(6)> Cielo.Recurrency.update_end_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", "2020-15-12")
      {:ok, :invalid_date}
  """
  @spec update_end_date(binary, binary) :: http_response()
  def update_end_date(recurrent_payment_id, new_date) when is_binary(new_date) do
    with {:ok, _date} <- Date.from_iso8601(new_date),
         {:ok, _} = response <- common_update_text(@update_enddate_endpoint, recurrent_payment_id, new_date) do
      response

    else
      error_tuple ->
        error_tuple
    end
  end

  def update_end_date(recurrent_payment_id, %Date{} = date), do: update_end_date(recurrent_payment_id, Date.to_string(date))
  def update_end_date(_recurrent_payment_id, _date), do: {:error, :invalid_parameters}

  @doc """
  Update a recurrent payment with next charge date, this call change the next date of charge but, mantain
  other payment dates same the original transaction.

  The date informed needs be ISO8601 format.

  ## Examples

      iex(1)> Cielo.Recurrency.update_next_charge_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", "2020-12-12")
      {:ok, :updated}

      iex(2)> Cielo.Recurrency.update_next_charge_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", ~D[2020-12-12])
      {:ok, :updated}

      iex(3)> Cielo.Recurrency.update_next_charge_date("26e5da86-d975-4e2f-aa25-862b5a44e8f6", 2)
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(4)> Cielo.Recurrency.update_next_charge_date("862b5a43e9f4", 15)
      {:ok, :invalid_guid}

      iex(5)> Cielo.Recurrency.update_next_charge_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", -15)
      {:ok, :invalid_parameters}

      iex(6)> Cielo.Recurrency.update_next_charge_date("26e5da86-d975-4e2f-aa25-862b5a43e9f4", "2020-15-12")
      {:ok, :invalid_date}
  """
  @spec update_next_charge_date(binary, binary) :: http_response()
  def update_next_charge_date(recurrent_payment_id, new_date) when is_binary(new_date) do
    with {:ok, _date} <- Date.from_iso8601(new_date),
         {:ok, _} = response <- common_update_text(@update_next_charge_date_endpoint, recurrent_payment_id, new_date) do
      response

    else
      error_tuple ->
        error_tuple
    end
  end

  def update_next_charge_date(recurrent_payment_id, %Date{} = date), do: update_next_charge_date(recurrent_payment_id, Date.to_string(date))
  def update_next_charge_date(_recurrent_payment_id, _date), do: {:error, :invalid_parameters}

  @doc """
  Update a recurrent payment interval,

  You can use atoms for predefined intervals.

  Valid intervals:
    - :monthly = 1
    - :bimonthly = 2
    - :quarterly = 3
    - :semi_annual = 6
    - :annual = 12

  ## Examples

      iex(1)> Cielo.Recurrency.update_interval("26e5da86-d975-4e2f-aa25-862b5a43e9f4", 2)
      {:ok, :updated}

      iex(2)> Cielo.Recurrency.update_interval("26e5da86-d975-4e2f-aa25-862b5a43e9f4", :bimonthly)
      {:ok, :updated}

      iex(3)> Cielo.Recurrency.update_interval("26e5da86-d975-4e2f-aa25-862b5a44e8f6", 2)
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(4)> Cielo.Recurrency.update_interval("862b5a43e9f4", 15)
      {:ok, :invalid_guid}

      iex(5)> Cielo.Recurrency.update_interval("862b5a43e9f4", -15)
      {:ok, :invalid_parameters}
  """
  @spec update_interval(binary, non_neg_integer | atom) :: http_response()
  def update_interval(recurrent_payment_id, interval) when is_integer(interval) do
    common_update_text(@update_interval_endpoint, recurrent_payment_id, interval)
  end

  def update_interval(recurrent_payment_id, interval) when is_atom(interval) and interval in @valid_intervals do
    update_interval(recurrent_payment_id, Utils.parse_interval(interval))
  end

  def update_interval(_recurrent_payment_id, _date), do: {:error, :invalid_parameters}

  @doc """
  Update a recurrent payment charge day

  ## Examples

      iex(1)> Cielo.Recurrency.update_charge_day("26e5da86-d975-4e2f-aa25-862b5a43e9f4", 15)
      {:ok, :updated}

      iex(2)> Cielo.Recurrency.update_charge_day("26e5da86-d975-4e2f-aa25-862b5a44e8f6", 15)
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(3)> Cielo.Recurrency.update_charge_day("26e5da86-d975-4e2f-aa25-862b5a43e9f4", 40)
      {:error, :bad_request, [%{code: 317, message: "Invalid Recurrency Day"}]}

      iex(4)> Cielo.Recurrency.update_charge_day("862b5a43e9f4", 15)
      {:ok, :invalid_guid}

      iex(5)> Cielo.Recurrency.update_charge_day("862b5a43e9f4", -15)
      {:ok, :invalid_parameters}
  """
  @spec update_charge_day(binary, non_neg_integer) :: http_response()
  def update_charge_day(recurrent_payment_id, charge_day) when is_integer(charge_day) do
    common_update_text(@update_charge_day_endpoint, recurrent_payment_id, charge_day)
  end

  def update_charge_day(_recurrent_payment_id, _date), do: {:error, :invalid_parameters}

  @doc """
  Update a recurrent payment amount

  ## Examples

      iex(1)> Cielo.Recurrency.update_amount("26e5da86-d975-4e2f-aa25-862b5a43e9f4", 1000)
      {:ok, :updated}

      iex(2)> Cielo.Recurrency.update_amount("26e5da86-d975-4e2f-aa25-862b5a44e8f6", 100)
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(3)> Cielo.Recurrency.update_amount("26e5da86-d975-4e2f-aa25-862b5a43e9f4", %{amount: 100})
      {:error, :invalid_parameters}

      iex(4)> Cielo.Recurrency.update_amount("1000", 100)
      {:error, :invalid_guid}
  """
  @spec update_amount(binary, non_neg_integer) :: http_response()
  def update_amount(recurrent_payment_id, amount) when is_integer(amount) do
    common_update_text(@update_amount_endpoint, recurrent_payment_id, amount)
  end

  def update_amount(_recurrent_payment_id, _date), do: {:error, :invalid_parameters}

  @doc """
  Reactivate a recurrent payment transaction

  ## Examples

      iex(1)> Cielo.Recurrency.reactivate("26e5da86-d975-4e2f-aa25-862b5a43e9f4")
      {:ok, :reactivated}

      iex(2)> Cielo.Recurrency.reactivate("26e5da86-d975-4e2f-aa25-862b5a44e8f6")
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(3)> Cielo.Recurrency.reactivate(100)
      {:error, :invalid_guid}
  """
  @spec reactivate(binary) :: http_response()
  def reactivate(recurrent_payment_id) do
    common_update_text(@reactivate_endpoint, recurrent_payment_id, "", :reactivated)
  end

  @doc """
  Deactivate a recurrent payment transaction

  ## Examples

      iex(1)> Cielo.Recurrency.deactivate("26e5da86-d975-4e2f-aa25-862b5a43e9f4")
      {:ok, :deactivated}

      iex(2)> Cielo.Recurrency.deactivate("26e5da86-d975-4e2f-aa25-862b5a44e8f6")
      {:error, :bad_request, [%{code: 313, message: "Recurrent Payment not found"}]}

      iex(3)> Cielo.Recurrency.deactivate(100)
      {:error, :invalid_guid}
  """
  @spec deactivate(binary) :: http_response()
  def deactivate(recurrent_payment_id) do
    common_update_text(@deactivate_endpoint, recurrent_payment_id, "", :deactivated)
  end

  defp common_update_text(endpoint, recurrent_payment_id, value, default_message \\ :updated) do
    if Utils.valid_guid?(recurrent_payment_id) do
      endpoint
      |> HTTP.build_path(":payment_id", "#{recurrent_payment_id}")
      |> HTTP.put(value, [request_format: :text])
      |> Utils.format_update_response(default_message)
    else
      {:error, :invalid_uuid}
    end
  end
end
