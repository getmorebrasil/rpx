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

  def init(_opts) do
    [host: host, connection_handler: connection_handler] = Application.get_env(:rpx, __MODULE__)

    state = %{
      connection_handler: connection_handler,
      connection_data: connection_handler.new(host)
    }

    {:ok, state}
  end

  def handle_call({:send, meta, message}, {pid, _}, state) do
    state.connection_handler.send(state.connection_data,
      Map.update!(meta, :correlation_id, &(serialize(pid) <> "," <> &1)),
      message)

    {:reply, :ok, state}
  end

  def handle_info({:basic_deliver, payload, %{correlation_id: correlation_id}}, state) do
    [pid, _] = String.split(correlation_id, ",")

    pid |> deserialize |> send(payload)

    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end

  @spec serialize(term) :: binary
  defp serialize(term) do
    term
    |> :erlang.term_to_binary
    |> Base.url_encode64
  end

  @spec deserialize(binary) :: term
  defp deserialize(str) when is_binary(str) do
    str
    |> Base.url_decode64!
    |> :erlang.binary_to_term
  end
end
