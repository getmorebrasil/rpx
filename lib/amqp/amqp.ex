defmodule RPX.AMQP do
  @moduledoc false

  defstruct [:connection, :channel]

  @spec new(String.t()) :: %RPX.AMQP{}
  def new(host) do
    {:ok, connection} = AMQP.Connection.open(host)
    {:ok, channel} = AMQP.Channel.open(connection)
    %RPX.AMQP{connection: connection, channel: channel}
  end

  @spec listen(%RPX.AMQP{}, String.t()) :: any()
  def listen(config, queue_name) do
    AMQP.Queue.declare(config.channel, queue_name)
    AMQP.Basic.qos(config.channel, prefetch_count: 1)
    AMQP.Basic.consume(config.channel, queue_name, nil, no_ack: true)
  end

  @spec listen(%RPX.AMQP{}, String.t()) :: any()
  def send(%RPX.AMQP{channel: channel}, meta, message) do
    AMQP.Basic.publish(
      channel,
      "",
      meta.queue_name,
      Jason.encode!(message),
      reply_to: meta.reply_to,
      correlation_id: meta.correlation_id
    )
  end
end
