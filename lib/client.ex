defmodule Client do
  @moduledoc """
  This module provides functions to call remote workers.
  """
  defstruct [:name, :connection_handler, :connection_data]

  def new(name, connection, connection_data) do
    %Client{
      name: name,
      connection_handler: connection,
      connection_data: connection_data,
    }
  end

  def call(client, target, args) do
    correlation_id = :erlang.unique_integer |> :erlang.integer_to_binary |> Base.encode64
    message = %{target: target, args: args}
    meta = %{correlation_id: correlation_id, reply_to: client.name <> "_callback"}

    client.connection_handler.send(client.connection_data, meta, message)

    Task.async(fn -> wait_for_messages(correlation_id) end)
  end

  defp wait_for_messages(correlation_id) do
    receive do
      {:basic_deliver, payload, %{correlation_id: ^correlation_id}} -> Jason.decode!(payload)
    end
  end
end
