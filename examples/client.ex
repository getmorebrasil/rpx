defmodule Example.Client do
  def test do
    Client.new("fila_de_teste", Connection.AMQP, Connection.AMQP.new("amqp://localhost:5672"))
    |> Client.call("boo", %{number: 1})
  end
end
