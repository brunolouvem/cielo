defmodule Cielo.HTTPTest do
  use ExUnit.Case

  alias Cielo.{HTTP, Utils}

  test "build_url/3 builds a url for sandbox" do
    with_config(:sandbox, true, fn ->
      assert HTTP.build_url("1/zeroauth", :post, []) =~
               "https://apisandbox.cieloecommerce.cielo.com.br/1/zeroauth"
    end)
  end

  test "build_url/3 builds a url for production" do
    with_config(:sandbox, false, fn ->
      assert HTTP.build_url("1/zeroauth", :post, []) =~
               "https://api.cieloecommerce.cielo.com.br/1/zeroauth"
    end)
  end

  test "build_url/3 builds a query url for sandbox" do
    with_config(:sandbox, true, fn ->
      assert HTTP.build_url("1/zeroauth", :get, []) =~
               "https://apiquerysandbox.cieloecommerce.cielo.com.br/1/zeroauth"
    end)
  end

  test "build_url/3 builds a query url for production" do
    with_config(:sandbox, false, fn ->
      assert HTTP.build_url("1/zeroauth", :get, []) =~
               "https://apiquery.cieloecommerce.cielo.com.br/1/zeroauth"
    end)
  end

  defp with_config(key, value, fun) do
    original = Utils.get_env(key, :none)

    try do
      Utils.put_env(key, value)
      fun.()
    after
      case original do
        :none -> Application.delete_env(:cielo, key)
        _ -> Utils.put_env(key, original)
      end
    end
  end
end
