defmodule RPX.AMQP.Server do
  @moduledoc false
  use GenServer

  # Server (callbacks)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init([worker: worker, queue_name: queue_name]) do
    [host: host] = Application.get_env(:rpx, __MODULE__)
    config = RPX.AMQP.new(host)
    RPX.AMQP.listen(config, queue_name)

    state = %{
      config: config,
      worker: worker
    }

    {:ok, state}
  end

  def handle_info({:basic_deliver, payload, meta}, state) do
    {target, params} = Jason.decode!(payload)

    Task.async(fn ->
      res = apply(state.worker, target, [params])
      RPX.AMQP.send(state.config, meta, res)
    end)

    {:noreply, state}
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end
end
