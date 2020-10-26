defmodule ClientServerTest do
  use ExUnit.Case
  doctest RPX.AMQP.Server
  doctest RPX.AMQP.Client

  alias RPX.AMQP.Client
  alias RPX.AMQP.Server

  describe "call" do
    test "Client should be able to call Server" do
      queue_name = "dummy_queue"
      children = [
        {Server, worker: DummyWorker, queue_name: queue_name},
        Client
      ]

      Supervisor.start_link(children, strategy: :one_for_one, name: Test.Supervisor)

      assert Task.await(Client.call(queue_name, "foo", %{})) == DummyWorker.foo(%{})
    end
  end
end
