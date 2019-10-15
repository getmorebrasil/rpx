defmodule Connection.Server.Test do
  use ExUnit.Case
  doctest Server

  setup_all do
    children = [
      {RPX.Connection, %{host: "amqp://localhost:5672", connection_handler: RPX.Connection.AMQP}}
    ]
    opts = [strategy: :one_for_one, name: Test.Supervisor]

    Supervisor.start_link(children, opts)

    RPX.Client.call("fila_de_teste","boo", %{number: 123})
  end
end
