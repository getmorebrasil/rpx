defmodule StubConnection do
  @behaviour Connection

  @impl Connection
  def new(_host), do: %{}
  @impl Connection
  def send(%{}, _meta, _message), do: nil
  @impl Connection
  def wait_for_message, do: nil
  @impl Connection
  def listen(%{}, _name), do: nil
end

defmodule StubWorker do
  def some_function(a, b), do: a + b
end

defmodule ServerTest do
  use ExUnit.Case
  doctest Server

  test "A new server should be created" do
    assert Server.new("Test", StubConnection, StubConnection.new("protocol://a")) == %Server{
      name: "Test",
      connection_handler: StubConnection,
      connection_data: %{},
      procedures: %{}
    }
  end

  test "A function should be added to the server" do
    server = Server.new("Test", StubConnection, StubConnection.new("protocol://a"))
    |> Server.add_procedure(&StubWorker.some_function/2)

    assert Map.has_key?(server.procedures, :some_function)
  end
end
