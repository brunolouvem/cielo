defmodule Cielo.HTTP do
  @moduledoc """
  HTTP Wrapper Module for all API's interaction,
  """

  require Logger

  alias Cielo.Utils

  @behaviour Cielo.HTTPBehaviour

  @type response ::
          {:ok, map | {:error, atom}}
          | {:error, Error.t()}
          | {:error, binary}

  @api_prefix "api"
  @sandbox_prefix "sandbox"

  @scheme "https://"
  @host "cieloecommerce.cielo.com.br/1"

  @headers [
    {"Accept", "application/json"},
    {"User-Agent", "Cielo Elixir/0.1"},
    {"Accept-Encoding", "identity"},
    {"Content-Type", "application/json"}
  ]

  @statuses %{
    400 => :bad_request,
    404 => :not_found,
    500 => :server_error
  }

  @doc false
  @spec encode_body(binary | map) :: binary
  defp encode_body(body) when body == "" or body == %{}, do: ""
  defp encode_body(body), do: Jason.encode!(body)

  @doc false
  @spec decode_body(binary) :: map | binary
  defp decode_body(body) do
    {:ok, body} =
      body
      |> :hackney.body()

    decode_json_body(body)
  end

  @spec decode_json_body(any) :: any
  defp decode_json_body(body) when body == "", do: ""

  defp decode_json_body(body) do
    body
    |> String.trim()
    |> IO.inspect()
    |> Jason.decode!()
    |> Utils.map_from_cielo()
  rescue
    Jason.DecodeError -> Logger.error("Unprocessable response")
  end

  @spec request(atom, binary, binary | map, Keyword.t()) :: response
  def request(method, path, body \\ %{}, opts \\ []) do
    body_params = Utils.map_to_cielo(body)

    try do
      :hackney.request(
        method,
        build_url(path, method, opts),
        build_headers(opts),
        encode_body(body_params),
        build_options()
      )
    catch
      kind, reason ->
        :erlang.raise(kind, reason, __STACKTRACE__)
    else
      {:ok, code, _headers, body} when code in 200..201 ->
        {:ok, decode_body(body)}

      {:ok, code, _headers, body} when code in 400..500 ->
        error_response(code_to_reason(code), decode_body(body))

      {:error, reason} ->
        {:error, reason}
    end
  end

  for method <- ~w(get post put)a do
    @method String.upcase(Atom.to_string(method))

    if @method == "GET" do
      @doc """
      Wrapp a hackey call with #{@method} verb passing only path to function
      ## Example

          iex> Cielo.HTTP.#{method}("/1/cardBin/538965")
          {:ok, %{
              card_type: "Débito",
              corporate_card: false,
              foreign_card: true,
              issuer: "Bradesco",
              issuer_code: "237",
              provider: "MASTERCARD",
              status: "00"
            }}

          iex> Cielo.HTTP.#{method}("/1/cardBin/000000")
          {:error, :not_found}
      """
    end

    @impl Cielo.HTTPBehaviour
    def unquote(method)(path) do
      request(unquote(method), path, %{}, [])
    end

    if @method != "GET" do
      @doc """
      Wrapp a hackey call with #{@method} verb passing path and payload to function

      ## Example

          iex> Cielo.HTTP.#{method}("/1/sales", %{merchant_order_id: order_key})
          {:ok, %{
              merchant_order_id: order_key,
              ...
            }}
      """
    end

    @impl Cielo.HTTPBehaviour
    def unquote(method)(path, payload) when is_map(payload) do
      request(unquote(method), path, payload, [])
    end

    if @method != "GET" do
      @doc """
      Wrapp a hackey call with #{@method} verb passing path and payload to function

      ## Example

          iex> Cielo.HTTP.#{method}("/1/sales", %{merchant_order_id: order_key})
          {:ok, %{
              merchant_order_id: order_key,
              ...
            }}
      """
    end

    @impl Cielo.HTTPBehaviour
    def unquote(method)(path, opts) when is_list(opts) do
      request(unquote(method), path, %{}, opts)
    end

    if @method != "GET" do
      @doc """
      Wrapp a hackey call with #{@method} verb passing path, payload and a configuration list

      ## Example

          iex> Cielo.HTTP.#{method}("/1/sales", %{merchant_order_id: order_key}, sandbox: true)
          {:ok, %{
              merchant_order_id: order_key,
              ...
            }}

      ## Valid options
      - `sandbox`: Redirect calls to sandbox API
      """
    end

    @impl Cielo.HTTPBehaviour
    def unquote(method)(path, payload, opts) do
      request(unquote(method), path, payload, opts)
    end
  end

  @doc false
  @spec build_headers(Keyword.t()) :: list()
  defp build_headers(opts) do
    merchant_id = get_lazy_env(opts, :merchant_id)
    merchant_key = get_lazy_env(opts, :merchant_key)

    [
      {"MerchantId", merchant_id},
      {"MerchantKey", merchant_key}
    ] ++ @headers
  end

  @doc false
  @spec build_options() :: [...]
  defp build_options, do: Utils.get_env(:http_options, [])

  @doc false
  @spec build_url(binary, atom(), Keyword.t()) :: binary
  defp build_url(path, method, opts) do
    environment = opts |> get_lazy_env(:sandbox) |> is_sandbox?()

    build_endpoint(environment, method) <> "/" <> path
  end

  @impl Cielo.HTTPBehaviour
  def build_path(path, search_key, replace) do
    String.replace(path, search_key, replace, global: false)
  end

  @doc false
  @spec code_to_reason(integer) :: atom
  defp code_to_reason(integer)

  for {code, status} <- @statuses do
    defp code_to_reason(unquote(code)), do: unquote(status)
  end

  defp error_response(reason, ""), do: {:error, reason}
  defp error_response(reason, detail), do: {:error, reason, detail}

  defp get_lazy_env(opts, key, default \\ nil) do
    Keyword.get_lazy(opts, key, fn -> Utils.get_env(key, default) end)
  end

  defp build_endpoint(sandbox, method) do
    @scheme
    |> maybe_get_method(method)
    |> maybe_sandbox(sandbox)
    |> Kernel.<>(".#{@host}")
  end

  defp maybe_get_method(value, :get), do: value <> "#{@api_prefix}query"
  defp maybe_get_method(value, _), do: value <> @api_prefix

  defp maybe_sandbox(value, :sandbox), do: value <> @sandbox_prefix
  defp maybe_sandbox(value, _), do: value

  defp is_sandbox?(false), do: :production
  defp is_sandbox?(true), do: :sandbox
end
