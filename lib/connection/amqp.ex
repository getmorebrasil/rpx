defmodule Connection.AMQP do
  @moduledoc """
  Connection implementation for AMQP.
  """
  @behaviour Connection

  defstruct [:connection, :channel, :queue_name]

  @impl Connection
  @spec new(String.t()) :: %Connection.AMQP{}
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
      meta.queue_name,
      Jason.encode!(message),
      reply_to: meta.reply_to,
      correlation_id: meta.correlation_id)
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
  def wait_for_message(correlation_id) do
    receive do
      {:basic_deliver, payload, %{correlation_id: ^correlation_id}} -> Jason.decode!(payload)
    end
  end

  @impl Connection
  def listen(connection, name) do
    AMQP.Queue.declare(connection.channel, name)
    AMQP.Basic.qos(connection.channel, prefetch_count: 1)
    AMQP.Basic.consume(connection.channel, name, nil, no_ack: true)
  end
end
