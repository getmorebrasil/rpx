import Config

config :rpx, RPX.AMQP.Client,
    host: "amqp://localhost"

config :rpx, RPX.AMQP.Server,
    host: "amqp://localhost"