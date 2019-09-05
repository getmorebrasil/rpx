
defmodule ServerTest do
  use ExUnit.Case
  doctest Server

  test "A new server should be created" do
    assert Server.new("Test", MockConnection, MockConnection.new("protocol://a")) == %Server{
      name: "Test",
      connection_handler: MockConnection,
      connection_data: %{},
      procedures: %{}
    }
  end

  test "A function should be added to the server" do
    server = Server.new("Test", MockConnection, MockConnection.new("protocol://a"))
    |> Server.add_procedure(&MockWorker.some_function/2)

    assert Map.has_key?(server.procedures, :some_function)
  end
end
