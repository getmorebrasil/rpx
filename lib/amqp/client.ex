defmodule RPX.AMQP.Client do
  @moduledoc false
  use GenServer

  @reply_to "amq.rabbitmq.reply-to"

  defstruct [:connection, :channel]

  # Client

  def call(queue_name, target, params) do
    Task.async(
      fn ->
        correlation_id = :erlang.unique_integer |> :erlang.integer_to_binary |> Base.encode64
        message = %{target: target, params: params}
        meta = %{correlation_id: correlation_id, reply_to: @reply_to, queue_name: queue_name}

        GenServer.call(__MODULE__, {:send, meta, message})
        receive do
          payload -> Jason.decode!(payload)
        end
      end
    )
  end

  # Server (callbacks)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_opts) do
    [host: host] = Application.get_env(:rpx, __MODULE__)
    config = RPX.AMQP.new(host)
    RPX.AMQP.listen(config, @reply_to)

    state = %{config: config}

    {:ok, state}
  end

  def handle_call({:send, meta, message}, {pid, _}, state) do
    RPX.AMQP.send(
      state.config,
      Map.update!(meta, :correlation_id, &(serialize(pid) <> "," <> &1)),
      message
    )

    {:reply, :ok, state}
  end

  def handle_info({:basic_deliver, payload, %{correlation_id: correlation_id}}, state) do
    [pid, _] = String.split(correlation_id, ",")

    pid |> deserialize |> send(payload)

    {:noreply, state}
  end

  def handle_info(msg, state) do
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
