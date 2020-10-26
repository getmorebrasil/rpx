defmodule DummyWorker do
  def foo(arg) do
    %{"response" => arg}
  end
end

ExUnit.start()
