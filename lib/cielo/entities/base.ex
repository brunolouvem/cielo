defmodule Cielo.Entities.Base do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      @moduledoc false
      use Ecto.Schema
      import Ecto.Changeset
    end
  end
end
