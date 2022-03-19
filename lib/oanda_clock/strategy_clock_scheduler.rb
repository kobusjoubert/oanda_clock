module OandaWorker
  class StrategyClockScheduler
    # Should queue this to rabbitmq jobs instead when load gets too high.
    def loop_over_accounts_in_production
      $logger.info 'LOOPING PRODUCTION strategy_clock_scheduler live accounts'
      StrategyClock.new(practice: false, environment: 'production').loop_over_accounts

      $logger.info 'LOOPING PRODUCTION strategy_clock_scheduler practice accounts'
      StrategyClock.new(practice: true, environment: 'production').loop_over_accounts
    end

    def loop_over_accounts_in_staging
      $logger.info 'LOOPING STAGING strategy_clock_scheduler live accounts'
      StrategyClock.new(practice: false, environment: 'staging').loop_over_accounts

      $logger.info 'LOOPING STAGING strategy_clock_scheduler practice accounts'
      StrategyClock.new(practice: true, environment: 'staging').loop_over_accounts
    end

    def loop_over_accounts_in_development
      $logger.info 'LOOPING DEVELOPMNET strategy_clock_scheduler live accounts'
      StrategyClock.new(practice: false, environment: 'development').loop_over_accounts

      $logger.info 'LOOPING DEVELOPMNET strategy_clock_scheduler practice accounts'
      StrategyClock.new(practice: true, environment: 'development').loop_over_accounts
    end
  end
end
