defmodule Cielo.HTTPBehaviour do
  @moduledoc false

  @type response ::
          {:ok, map | {:error, atom}}
          | {:error, Error.t()}
          | {:error, binary}

  @callback build_path(binary, binary, binary) :: binary

  for method <- ~w(get post put)a do
    @method String.upcase(Atom.to_string(method))

    @doc """
    Called to #{@method} call in hackney wrapper, only with binary path

    Return a `response` type
    """
    @callback unquote(method)(binary) :: response

    @doc """
    Called to #{@method} call in hackney wrapper, but with binary path and map for parameters or config list

    Return a `response` type
    """
    @callback unquote(method)(binary, binary | map | list) :: response

    @doc """
    Called to #{@method} call in hackney wrapper, but with binary path, map for parameters and config list

    Return a `response` type
    """
    @callback unquote(method)(binary, map, list) :: response
  end
end
