defmodule RPX.Connection.AMQP do
  @moduledoc """
  Connection implementation for AMQP.
  """
  @behaviour RPX.Protocol

  defstruct [:connection, :channel]

  @impl RPX.Protocol
  @spec new(String.t()) :: %RPX.Connection.AMQP{}
  def new(host) do
    {:ok, connection} = AMQP.Connection.open(host)
    {:ok, channel} = AMQP.Channel.open(connection)
    config = %RPX.Connection.AMQP{connection: connection, channel: channel}

    listen(config)
    config
  end

  @impl RPX.Protocol
  def send(%RPX.Connection.AMQP{channel: channel}, meta, message) do
    AMQP.Basic.publish(
      channel,
      "",
      meta.queue_name,
      Jason.encode!(message),
      reply_to: meta.reply_to,
      correlation_id: meta.correlation_id)
  end

  @impl RPX.Protocol
  def wait_for_message do
    {payload, meta} = receive do
      {:basic_deliver, payload, meta} -> {payload, meta}
    end

    {target, params} = Jason.decode!(payload)
    {target, params, meta}
  end

  @impl RPX.Protocol
  def wait_for_message(correlation_id) do
    receive do
      {:basic_deliver, payload, %{correlation_id: ^correlation_id}} -> Jason.decode!(payload)
    end
  end

  @impl RPX.Protocol
  def listen(connection) do
    AMQP.Queue.declare(connection.channel, "amq.rabbitmq.reply-to")
    AMQP.Basic.qos(connection.channel, prefetch_count: 1)
    AMQP.Basic.consume(connection.channel, "amq.rabbitmq.reply-to", nil, no_ack: true)
  end
end
