defmodule Cielo.ConfigurationError do
  @moduledoc """
  Raised when a config variable is missing and fallback was not passed.
  """

  defexception [:message]

  @doc """
  Build a new ConfigurationError exception.
  """
  @impl true
  def exception(value), do: %__MODULE__{message: "missing config for :#{value}"}
end
