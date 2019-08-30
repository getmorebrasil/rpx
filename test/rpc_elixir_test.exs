defmodule RpcElixirTest do
  use ExUnit.Case
  doctest RpcElixir

  test "greets the world" do
    assert RpcElixir.hello() == :world
  end
end
