defmodule RPX.Protocol do
  @moduledoc """
  Behaviour defining an interface for connections.
  """

  @doc "Creates a new connection."
  @callback new(String.t()) :: struct()
  @doc "Sends response message back to the caller."
  @callback send(struct(), any(), any()) :: any()
  @doc "Waits for messages from callers."
  @callback wait_for_message() :: {String.t(), %{}, %{}}
  @doc "Waits for message with given correlation id."
  @callback wait_for_message(String.t()) :: {String.t(), %{}, %{}}
  @doc "Starts to consume some queue or endpoint."
  @callback listen(Connection) :: no_return()
end
