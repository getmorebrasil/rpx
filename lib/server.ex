defmodule Server do
  @moduledoc """
  This module provides the core server functions and the server abstractions.
  The server is a worker which will receive requests from a remote client.
  """

  defstruct [:name, :connection_handler, :connection_data, :procedures]

  @doc """
  Creates a new Server struct.

  # Parameters
  	- name: String Server name. Should be unique since a RabbitMQ queue will be created for this Server.
    - connection: Connection module which this server will use.
    - connection_data: Metadata used by the connection module.
  """
  def new(name, connection, connection_data) do
    %Server{
      name: name,
      connection_handler: connection,
      connection_data: connection_data,
      procedures: %{}
    }
  end

  @doc """
  Adds a function to some provided %Server

  ## Parameters
  	- server: %Server to which the function will be added.
  	- new_procedure: Function to be added to the %Server.

  ## Examples
  	Server.new("Sum server", Connection.AMQP, Connection.new("amqp://localhost:5672"))
  	|> Server.add_procedure(&some_function/1)
  """
  def add_procedure(server, new_procedure) do
    func_name = Function.info(new_procedure) |> Keyword.get(:name)

    %Server{server | procedures: Map.put(server.procedures, func_name, new_procedure)}
  end

  @doc """
  Starts listening with the %Server functions

  ## Parameters
  	- server: %Server to be started

  ## Examples
  	Server.new("Sum server", "amqp://localhost:5672")
  	|> Server.add_procedure(&MyModule.my_function/1)
  	|> Server.start
  """
  def start(server) do
    server.connection_handler.listen(server.connection_data, server.name)
    listen(server)
  end

  defp listen(server) do
    {target, args, meta} = server.connection_handler.wait_for_message(server)
    dispatch(server, meta, target, args)
    listen(server)
  end

  defp dispatch(server, meta, target, args) do
    spawn(fn ->
      func = Map.get(server.procedures, target) || %{response: "The provided target #{target} is not implemented by this server."}
      response = func.(args)
      server.connection_handler.send(server.connection_data, meta, response)
    end)
  end
end
