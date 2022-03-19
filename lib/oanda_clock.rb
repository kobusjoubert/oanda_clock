root = File.expand_path('../lib', File.dirname(__FILE__))
$: << root # Same as `$LOAD_PATH << root`

require 'dotenv'
Dotenv.load

require 'logger'
require 'json'
require 'redis'
require 'bunny'
require 'clockwork'
require 'oanda_clock/version'
require 'oanda_clock/clock'
require 'oanda_clock/indicator_clock'
require 'oanda_clock/indicator_clock_scheduler'
require 'oanda_clock/strategy_clock'
require 'oanda_clock/strategy_clock_scheduler'
require 'oanda_clock/data_clock'
require 'oanda_clock/data_clock_scheduler'

if ENV['APP_ENV'] == 'development'
  require 'byebug'
end

# Logger.
$logger = Logger.new(STDOUT)
$logger.level = ENV['APP_ENV'] == 'development' ? Logger::DEBUG : Logger::INFO

# Redis.
if ENV['APP_ENV'] == 'development'
  $redis_development = Redis.new(url: ENV['REDIS_URL'])
else
  $redis_production  = Redis.new(url: ENV['REDIS_URL_PRODUCTION'])
  $redis_staging     = Redis.new(url: ENV['REDIS_URL_STAGING'])
end

# RabbitMQ Publisher.
if ENV['APP_ENV'] == 'development'
  url_publisher_development        = ENV['CLOUDAMQP_URL'] || 'amqp://guest:guest@localhost:5672'
  $rabbitmq_connection_development = Bunny.new(url_publisher_development)
  $rabbitmq_connection_development.start
  $rabbitmq_channel_development    = $rabbitmq_connection_development.create_channel
  $rabbitmq_exchange_development   = $rabbitmq_channel_development.direct('oanda_app', durable: true)
else
  url_publisher_production         = ENV['CLOUDAMQP_URL_PRODUCTION'] || 'amqp://guest:guest@localhost:5672'
  $rabbitmq_connection_production  = Bunny.new(url_publisher_production)
  $rabbitmq_connection_production.start
  $rabbitmq_channel_production     = $rabbitmq_connection_production.create_channel
  $rabbitmq_exchange_production    = $rabbitmq_channel_production.direct('oanda_app', durable: true)

  url_publisher_staging            = ENV['CLOUDAMQP_URL_STAGING'] || 'amqp://guest:guest@localhost:5672'
  $rabbitmq_connection_staging     = Bunny.new(url_publisher_staging)
  $rabbitmq_connection_staging.start
  $rabbitmq_channel_staging        = $rabbitmq_connection_staging.create_channel
  $rabbitmq_exchange_staging       = $rabbitmq_channel_staging.direct('oanda_app', durable: true)
end
