defmodule MockProtocol do
  @behaviour RPX.Protocol

  @impl RPX.Protocol
  def new(_host), do: %{}
  @impl RPX.Protocol
  def send(%{}, _meta, _message), do: nil
  @impl RPX.Protocol
  def wait_for_message, do: nil
  @impl RPX.Protocol
  def wait_for_message(_), do: nil
  @impl RPX.Protocol
  def listen(%{}, _name), do: nil
end

defmodule MockWorker do
  def some_function(a, b), do: a + b
end

ExUnit.start()
