defmodule ClientTest do
  use ExUnit.Case
  doctest RPX.AMQP.Client
  alias RPX.AMQP.Client
  
  describe "init/1" do
    test "initializes Client" do
      Client.init(nil)
    end
  end

  describe "call/3" do
    test "handles function call correctly" do
      {:ok, state} = Client.init(nil)

      meta = %{correlation_id: "123", queue_name: "rpx_test", reply_to: "amq.rabbitmq.reply-to"}
      
      assert Client.handle_call({:send, meta, %{target: "abc", params: []}}, {self(), {}}, state) ==
             {:reply, :ok, state}
    end
  end
end
  