defmodule RPX.Connection do
  use GenServer

  # Client

  def send(meta, message) do
    GenServer.call(__MODULE__, {:send, meta, message})
  end

  def wait_for_message(meta) do
    GenServer.call(__MODULE__, {:wait_for_message, meta})
  end

  # Server (callbacks)

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(%{host: host, connection_handler: connection_handler}) do
    config = %{
      connection_handler: connection_handler,
      connection_data: connection_handler.new(host)
    }

    {:ok, config}
  end

  def handle_call({:send, meta, message}, _from, config) do
    config.connection_handler.send(config.connection_data, meta, message)
    
    {:reply, :ok, config}
  end

  def handle_call({:wait_for_message, meta}, _from, config) do
    res = Task.async(fn -> config.connection_handler.wait_for_message(meta) end)
    
    {:reply, res, config}
  end
end
