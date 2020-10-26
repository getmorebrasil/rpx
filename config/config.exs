import Config

import_config "#{Mix.env()}.exs"

config :rpx, RPX.AMQP.Client, host: "amqp://localhost"

config :rpx, RPX.AMQP.Server, host: "amqp://localhost"
