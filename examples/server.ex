defmodule Example.Server do
  alias RPX.AMQP.Server

  def start() do
    {:ok, config} = Server.init(worker: DummyWorker, queue_name: "rpx_test")
  end
end
