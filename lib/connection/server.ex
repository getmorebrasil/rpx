defmodule RPX.Connection do
  use GenServer

  # Client

  def call(meta, message) do
    GenServer.call(__MODULE__, {:send, meta, message})

    receive do
      payload -> payload
    end
  end

  # Server (callbacks)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(%{host: host, connection_handler: connection_handler}) do
    state = %{
      connection_handler: connection_handler,
      connection_data: connection_handler.new(host)
    }

    {:ok, state}
  end

  def handle_call({:send, meta, message}, {pid, _}, state) do
    IO.inspect(Map.put(meta, :correlation_id, &(pid <> "," <> &1)) )
    state.connection_handler.send(state.connection_data, 
      Map.update!(meta, :correlation_id, &(pid <> "," <> &1)),
      message)

    {:reply, :ok, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg)
    #{:basic_deliver, payload, %{correlation_id: correlation_id}} = msg
    #[pid, _] = String.split(correlation_id, ",")
    
    #Kernel.send(pid, payload)

    {:noreply, state}
  end
end
