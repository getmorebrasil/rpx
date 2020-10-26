defmodule Example.Client do
  alias RPX.AMQP.Client

  def test do
    {:ok, state} = Client.init(nil)

    meta = %{correlation_id: "123", queue_name: "rpx_test", reply_to: "amq.rabbitmq.reply-to"}

    Client.handle_call({:send, meta, %{target: "abc", params: []}}, {self(), {}}, state)
  end
end
