defmodule Connection do
  @doc "Creates a new connection"
  @callback new(String.t()) :: struct()
  @callback send(struct(), any(), any()) :: any()
  @callback wait_for_message() :: {String.t(), %{}, %{}}
  @callback listen(Connection, String.t()) :: no_return()
end

defmodule Connection.AMQP do
  @behaviour Connection

  defstruct [:connection, :channel]

  def new(host) do
    {:ok, connection} = AMQP.Connection.open(host)
    {:ok, channel} = AMQP.Channel.open(connection)
    %Connection.AMQP{connection: connection, channel: channel}
  end

  def send(%Connection.AMQP{channel: channel}, meta, message) do
    AMQP.Basic.publish(
      channel,
      "",
      meta.reply_to,
      Jason.encode!(message),
      correlation_id: meta.correlation_id)
    AMQP.Basic.ack(channel, meta.delivery_tag)
  end

  def wait_for_message() do
    {payload, meta} = receive do
      {:basic_deliver, payload, meta} -> {payload, meta}
    end

    {target, params} = Jason.decode!(payload)
    {target, params, meta}
  end

  def listen(connection, name) do
    AMQP.Queue.declare(connection.channel, name)
		AMQP.Basic.qos(connection.channel, prefetch_count: 1)
		AMQP.Basic.consume(connection.channel, name)
  end
end
