defmodule Connection.AMQP do
  @moduledoc """
  Connection implementation for AMQP.
  """
  @behaviour Connection

  defstruct [:connection, :channel]

  @impl Connection
  def new(host) do
    {:ok, connection} = AMQP.Connection.open(host)
    {:ok, channel} = AMQP.Channel.open(connection)
    %Connection.AMQP{connection: connection, channel: channel}
  end

  @impl Connection
  def send(%Connection.AMQP{channel: channel}, meta, message) do
    AMQP.Basic.publish(
      channel,
      "",
      meta.reply_to,
      Jason.encode!(message),
      correlation_id: meta.correlation_id)
    AMQP.Basic.ack(channel, meta.delivery_tag)
  end

  @impl Connection
  def wait_for_message do
    {payload, meta} = receive do
      {:basic_deliver, payload, meta} -> {payload, meta}
    end

    {target, params} = Jason.decode!(payload)
    {target, params, meta}
  end

  @impl Connection
  def listen(connection, name) do
    AMQP.Queue.declare(connection.channel, name)
    AMQP.Basic.qos(connection.channel, prefetch_count: 1)
    AMQP.Basic.consume(connection.channel, name)
  end
end
