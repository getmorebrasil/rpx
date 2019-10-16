defmodule RPX.Client do
  @moduledoc """
  This module provides functions to call remote workers.
  """
  defstruct [:name, :connection_handler, :connection_data]

  @doc """
  Calls some function from a remote worker returnig a Task representing its
  response.

  ## Parameters
    - name: Name of the queue which the remote worker is listening to.
    - target: Worker function name to be called.
    - params: Arguments to be provided to the target function.
  ## Examples
      iex> RPX.Client.call("some_worker_queue", "sum", %{a: 1, b: 2}) |> Task.await
      %{"response" => 3}
  """
  @spec call(String.t(), String.t(), map()) :: %Task{}
  def call(name, target, params) do
    correlation_id = :erlang.unique_integer |> :erlang.integer_to_binary |> Base.encode64
    message = %{target: target, params: params}
    meta = %{correlation_id: correlation_id, reply_to: "amq.rabbitmq.reply-to", queue_name: name}

    Task.async(fn -> RPX.Connection.call(meta, message) |> Jason.decode! end)
  end
end
