defprotocol Connection do
  @doc "Creates a new connection"
  def new()
  def send()
  def receive()
  def listen()
end

defimpl Connection, for: AMQP do
  defstruct [:connection, :channel]

  def new() do
    {:ok, connection} = AMQP.Connection.open(host)
    {:ok, channel} = AMQP.Channel.open(connection)
    %Connection{connection: connection, channel: channel}
  end

  def send() do
    AMQP.Basic.publish(
      channel,
      "",
      meta.reply_to,
      Jason.encode!(response),
      correlation_id: meta.correlation_id)
    AMQP.Basic.ack(channel, meta.delivery_tag)
  end

  def receive() do

  end

  def listen() do
    AMQP.Queue.declare(server.channel, server.name)
		AMQP.Basic.qos(server.channel, prefetch_count: 1)
		AMQP.Basic.consume(server.channel, server.name)
  end
end
