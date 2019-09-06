defmodule Client do
  @moduledoc """
  This module provides functions to call remote workers.
  """
  defstruct [:name, :connection_handler, :connection_data]

  def new(name, connection_handler, connection_data) do
    connection_handler.listen(connection_data, "amq.rabbitmq.reply-to")
    %Client{
      name: name,
      connection_handler: connection_handler,
      connection_data: connection_data,
    }
  end

  def call(client, target, params) do
    correlation_id = :erlang.unique_integer |> :erlang.integer_to_binary |> Base.encode64
    message = %{target: target, params: params}
    meta = %{correlation_id: correlation_id, reply_to: "amq.rabbitmq.reply-to"}

    client.connection_handler.send(client.connection_data, meta, message)

    client.connection_handler.wait_for_message(correlation_id)
  end
end
