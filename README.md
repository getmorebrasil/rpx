# RPX

**A simple way to write RPC Clients and Servers in Elixir**

RPX allows you to easily define your RPC Servers and call its functions from a Client. Currently AMQP is the only supported connection protocol, but others might be implemented as well. The next goal of this library is to create a DSL to make Servers definition more straightforward.

## Usage


1. Put your RPX config inside config.exs
```
config :rpx, RPX.AMQP.Client,
  host: "amqp://localhost:5672",
```

2. Start the connection with your Supervisor
```
children = [
    RPX.AMPQ.Client
]
opts = [strategy: :one_for_one, name: Test.Supervisor]

Supervisor.start_link(children, opts)
```

3. Call your remote workers
```
iex> RPX.Client.call("some_worker_queue", "boo", %{number: 123})

```