defmodule MockConnection do
  @behaviour Connection

  @impl Connection
  def new(_host), do: %{}
  @impl Connection
  def send(%{}, _meta, _message), do: nil
  @impl Connection
  def wait_for_message, do: nil
  @impl Connection
  def listen(%{}, _name), do: nil
end

defmodule MockWorker do
  def some_function(a, b), do: a + b
end

ExUnit.start()
