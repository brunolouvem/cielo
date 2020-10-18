defmodule Cielo.Utils do
  @moduledoc """
  This module is a helper, providing helper functions
  """

  @doc """
  Helper function for retrieving cielo environment values, but
  will raise an exception if values are missing.
  ## Example
      iex> Cielo.get_env(:random_value)
      ** (Cielo.ConfigError) missing config for :random_value
      iex> Cielo.get_env(:random_value, "random")
      "random"
      iex> Application.put_env(:cielo, :random_value, "not-random")
      ...> value = Cielo.get_env(:random_value)
      ...> Application.delete_env(:cielo, :random_value)
      ...> value
      "not-random"
      iex> System.put_env("RANDOM", "not-random")
      ...> Application.put_env(:cielo, :system_value, {:system, "RANDOM"})
      ...> value = Cielo.get_env(:system_value)
      ...> System.delete_env("RANDOM")
      ...> value
      "not-random"
  """
  @spec get_env(atom, any) :: any
  def get_env(key, default \\ nil) do
    case Application.fetch_env(:cielo, key) do
      {:ok, {:system, var}} when is_binary(var) ->
        handle_exception(var, System.get_env(var), default)

      {:ok, value} ->
        value

      :error ->
        handle_exception(key, nil, default)
    end
  end

  @doc """
  Helper function for setting `cielo` application environment
  variables.
  ## Example
      iex> Cielo.put_env(:thingy, "thing")
      ...> Cielo.get_env(:thingy)
      "thing"
  """
  @spec put_env(atom, any) :: :ok
  def put_env(key, value) do
    Application.put_env(:cielo, key, value)
  end

  defp handle_exception(key, nil, nil), do: raise(Cielo.ConfigurationError, key)
  defp handle_exception(_, nil, default), do: default
  defp handle_exception(_, value, _), do: value

  def changeset_errors(%Ecto.Changeset{valid?: false, changes: changes, errors: []}) do
    Enum.reduce(changes, %{errors: []}, fn {key, change}, acc ->
      case change do
        %Ecto.Changeset{valid?: false} ->
          Map.put(acc, :errors, [{key, changeset_errors(change)} | acc.errors])

        _ ->
          acc
      end
    end)
  end

  def changeset_errors(%Ecto.Changeset{valid?: false, errors: errors}) do
    Enum.reduce(errors, %{errors: []}, fn {key, {error, _}}, acc ->
      Map.put(acc, :errors, [{key, error} | acc.errors])
    end)
  end

  @doc """
  Convert cielo map response to atom keyed map.

  ## Examples
      iex> %{"MerchantOrderId" => "7c17771a-1b66-494f-bb73-517f236dc9fe"} |> map_from_cielo()
      %{merchant_order_id: "7c17771a-1b66-494f-bb73-517f236dc9fe"}

      iex> %{merchant_order_id: "7c17771a-1b66-494f-bb73-517f236dc9fe"} |> map_from_cielo()
      %{merchant_order_id: "7c17771a-1b66-494f-bb73-517f236dc9fe"}
  """
  def map_from_cielo(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {map_key, map_value}, acc ->
      atom_map_key = convert_map_key(map_key, :atom)

      map_value = map_from_cielo(map_value)

      Map.put_new(acc, atom_map_key, map_value)
    end)
  end

  def map_from_cielo(list) when is_list(list) do
    Enum.map(list, &map_from_cielo/1)
  end

  def map_from_cielo(value), do: value

  @doc """
  Convert atom keyed map for a Cielo's valid map.

  ## Examples
      iex> %{merchant_order_id: "7c17771a-1b66-494f-bb73-517f236dc9fe"} |> map_from_cielo()
      %{"MerchantOrderId" => "7c17771a-1b66-494f-bb73-517f236dc9fe"}

      iex> %{"MerchantOrderId" => "7c17771a-1b66-494f-bb73-517f236dc9fe"} |> map_from_cielo()
      %{"MerchantOrderId" => "7c17771a-1b66-494f-bb73-517f236dc9fe"}
  """
  def map_to_cielo(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {map_key, map_value}, acc ->
      atom_map_key = convert_map_key(map_key, :string)

      map_value = map_to_cielo(map_value)

      Map.put_new(acc, atom_map_key, map_value)
    end)
  end

  def map_to_cielo(list) when is_list(list) do
    Enum.map(list, &map_to_cielo/1)
  end

  def map_to_cielo(value), do: value

  defp convert_map_key(key, :atom) when is_atom(key), do: key

  defp convert_map_key(key, :atom) when is_binary(key) do
    key
    |> camel_to_snake_string()
    |> String.to_atom()
  end

  defp convert_map_key(key, :string) when is_binary(key), do: key

  defp convert_map_key(key, :string) when is_atom(key) do
    key
    |> Atom.to_string()
    |> snake_to_camel_string()
  end

  defp camel_to_snake_string(name) do
    Regex.scan(~r/([A-Za-z][a-z]+)/, name)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.join("_")
    |> String.downcase()
  end

  defp snake_to_camel_string(name) do
    Regex.scan(~r/([a-z]+)/, name)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join("")
  end
end
