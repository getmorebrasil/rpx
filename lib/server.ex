defmodule Server do
    @moduledoc """
    This module provides the core server functions and the server abstractions.
    The server is a worker who will receive requests from a remote client.
    """
    use AMQP

    defstruct [:connection, :channel, :procedures]

    @doc """
    Creates a new Server struct.

    # Parameters
        - host: String URL for the RabbitMQ server.
    """
    @spec new(String.t()) :: %Server{}
    def new(host) do
        {:ok, connection} = AMQP.Connection.open(host)
        {:ok, channel} = AMQP.Channel.open(connection)
        %Server{connection: connection, channel: channel, procedures: []}
	end

    @doc """
    Adds a function to some provided %Server

    ## Parameters

        - server: %Server to which the function will be added.
        - new_procedure: Function to be added to the %Server.

    ## Examples
        Server.new()
        |> Server.add_procedure(&(&1 + &2))
    """
    @spec add_procedure(%Server{}, (... -> any)) :: %Server{}
    def add_procedure(%Server{connection: connection, channel: channel, procedures: procedures}, new_procedure) do
        %Server{connection: connection, channel: channel, procedures: [new_procedure | procedures]}
    end
end
