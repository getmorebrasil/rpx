defmodule RPX.Client do
  @moduledoc """
  This module provides functions to call remote workers.
  """
  defstruct [:name, :connection_handler, :connection_data]

  @doc """

  """
  def call(name, target, params) do
    correlation_id = :erlang.unique_integer |> :erlang.integer_to_binary |> Base.encode64
    message = %{target: target, params: params}
    meta = %{correlation_id: correlation_id, reply_to: "amq.rabbitmq.reply-to", queue_name: name}

    RPX.Connection.send(meta, message)
    #RPX.Connection.wait_for_message(correlation_id)
  end
end
