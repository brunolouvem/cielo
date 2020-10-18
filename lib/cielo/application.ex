defmodule Cielo.Application do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Cielo.Worker.start_link(arg)
      # {Cielo.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cielo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defmacro __using__(_opts) do
    quote do
      @doc false
      def adapter(), do: Cielo.Utils.get_env(:adapter, Cielo.HTTP)
    end
  end
end
