defmodule ServerTest do
  use ExUnit.Case
  doctest RPX.AMQP.Server
  alias RPX.AMQP.Server

  describe "init/1" do
    test "initializes Server" do
      {:ok, config} = Server.init([worker: DummyWorker, queue_name: "rpx_test"])
      assert DummyWorker = config.worker
    end
  end
end
