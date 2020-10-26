defmodule DummyWorker do
  def foo(arg) do
    %{"response" => arg}
  end
end

defmodule Main do
  alias RPX.AMQP.Server
  alias RPX.AMQP.Client

  @queue_name "banana_queue"

  def start_connection() do
    children = [{Server, worker: DummyWorker, queue_name: @queue_name}, Client]
    Supervisor.start_link(children, strategy: :one_for_one, name: Test.Supervisor)
  end

  def send_msg() do
    Task.await(Client.call(@queue_name, "foo", %{abobora: "fruto"}))
  end
end
