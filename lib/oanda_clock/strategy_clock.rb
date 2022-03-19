class StrategyClock
  REQUIRED_ATTRIBUTES = [:practice, :environment].freeze

  attr_accessor :practice, :environment
  attr_reader   :practice_or_live, :accounts

  def initialize(options = {})
    missing_attributes = REQUIRED_ATTRIBUTES - options.keys
    raise ArgumentError, "The #{missing_attributes} attributes are missing" unless missing_attributes.empty?

    options.each do |key, value|
      self.send("#{key}=", value) if self.respond_to?("#{key}=")
    end

    @practice_or_live = practice ? 'practice' : 'live'
    @accounts         = {}
  end

  def loop_over_accounts
    case environment
    when 'production'
      $redis_production.scan_each(match: "#{practice_or_live}:*:status") do |key|
        process_key(key)
      end
    when 'staging'
      $redis_staging.scan_each(match: "#{practice_or_live}:*:status") do |key|
        process_key(key)
      end
    when 'development'
      $redis_development.scan_each(match: "#{practice_or_live}:*:status") do |key|
        process_key(key)
      end
    end

    publish_to_rabbit
  end

  private

  def process_key(key)
    case environment
    when 'production'
      status = $redis_production.get(key)
    when 'staging'
      status = $redis_staging.get(key)
    when 'development'
      status = $redis_development.get(key)
    end

    case status
    when 'started', 'temporary_halted'
      account  = key.gsub(/:\d{5}:status/, '')
      strategy = key.split(':')[4]

      accounts[account] ||= []
      accounts[account] << strategy
    when 'paused', 'halted'
      # Skip.
    end
  end

  def publish_to_rabbit
    accounts.each do |key, value|
      data = { action: 'run_strategies', key_base: key, strategies: value }

      case environment
      when 'production'
        $rabbitmq_exchange_production.publish(data.to_json, routing_key: 'qw_strategy_run_all')
        $logger.info "PUBLISHED PRODUCTION to qw_strategy_run_all. key_base: #{key}, strategies: #{value}"
      when 'staging'
        $rabbitmq_exchange_staging.publish(data.to_json, routing_key: 'qw_strategy_run_all')
        $logger.info "PUBLISHED STAGING to qw_strategy_run_all. key_base: #{key}, strategies: #{value}"
      when 'development'
        $rabbitmq_exchange_development.publish(data.to_json, routing_key: 'qw_strategy_run_all')
        $logger.info "PUBLISHED DEVELOPMENT to qw_strategy_run_all. key_base: #{key}, strategies: #{value}"
      end
    end
  end
end
