defmodule RPX.Connection do
  use GenServer

  def send(meta, message) do
    GenServer.call(__MODULE__, {:send, meta, message})
  end

  def wait_for_message(meta) do
    GenServer.call(__MODULE__, {:wait_for_message, meta})
  end

  def child_spec(opts) do
    %{
      id: RPX.Connection,
      start: {__MODULE__, :start_link, [opts]},
      shutdown: 5_000,
      restart: :permanent,
      type: :worker,
    }
  end

  def start_link(%{host: host, connection_handler: connection_handler}) do
    config = connection_handler.new(host)
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_call({:send, meta, message}, _from, config) do
    config.connection_handler.send(config.connection_data, meta, message)
  end

  def handle_call({:wait_for_message, meta}, _from, config) do
    config.connection_handler.send(config.connection_data, meta)

    Task.async(fn -> config.connection_handler.wait_for_message(meta) end)
  end
end
