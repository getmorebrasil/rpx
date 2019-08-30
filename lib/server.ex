defmodule Server do
	@moduledoc """
	This module provides the core server functions and the server abstractions.
	The server is a worker which will receive requests from a remote client.
	"""
	use AMQP

	@nonExistingTargetResponse quote do: %{ response: "The provided target #{target} is not implemented by this server."}

	defstruct [:name, :connection, :channel, :procedures]

	@doc """
	Creates a new Server struct.

	# Parameters
		- name: String Server name. Should be unique since a RabbitMQ queue will be created for this Server.
		- host: String URL for the RabbitMQ server.
	"""
	@spec new(String.t(), String.t()) :: %Server{}
	def new(name, host) do
		{:ok, connection} = AMQP.Connection.open(host)
		{:ok, channel} = AMQP.Channel.open(connection)
		%Server{name: name, connection: connection, channel: channel, procedures: %{}}
	end

	@doc """
	Adds a function to some provided %Server

	## Parameters
		- server: %Server to which the function will be added.
		- new_procedure: Function to be added to the %Server.

	## Examples
		Server.new("Sum server", "amqp://localhost:5672")
		|> Server.add_procedure(&(&1 + &2))
	"""
	@spec add_procedure(%Server{}, (... -> any)) :: %Server{}
	def add_procedure(%Server{connection: connection, channel: channel, procedures: procedures}, new_procedure) do
		name = Function.info(new_procedure) |> Keyword.get(:name)
		%Server{connection: connection, channel: channel, procedures: Map.put(procedures, name, new_procedure)}
	end

	@doc """
	Starts listening with the %Server functions

	## Parameters
		- server: %Server to be started

	## Examples
		Server.new("Sum server", "amqp://localhost:5672")
		|> Server.add_procedure(MyModule.my_function)
		|> Server.start
	"""
	@spec start(%Server{}) :: none()
	def start(server) do
		AMQP.Queue.declare(server.channel, server.name)
		AMQP.Basic.qos(server.channel, prefetch_count: 1)
		AMQP.Basic.consume(server.channel, server.name)

		listen(server)
	end

	@spec listen(%Server{}) :: none()
	defp listen(server) do
		receive do
			{:basic_deliver, payload, meta} ->
				{target, args} = Jason.decode!(payload)
				response = dispatch(server, meta, target, args)

				AMQP.Basic.publish(
					server.channel,
					"",
					meta.reply_to,
					Jason.encode!(response),
					correlation_id: meta.correlation_id)
				AMQP.Basic.ack(server.channel, meta.delivery_tag)
		end
		listen(server)
	end

	@spec dispatch(%Server{}, Meta.t, String.t(), %{}) :: none()
	defp dispatch(server, meta, target, args) do
		spawn(
			fn ->
				func = Map.get(server.procedures, target) || @nonExistingTargetResponse
				response = func.(args)

				AMQP.Basic.publish(
					server.channel,
					"",
					meta.reply_to,
					Jason.encode!(response),
					correlation_id: meta.correlation_id)
				AMQP.Basic.ack(server.channel, meta.delivery_tag)
			end
		)
	end
end
