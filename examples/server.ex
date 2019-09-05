defmodule Example.Server do

  def sum(%{a: a, b: b}), do: a + b

  def start() do
    Server.new("example", Connection.AMQP, Connection.AMQP.new("amqp://localhost:5672"))
    |> Server.add_procedure(&sum/1)
    |> Server.start
  end
end
