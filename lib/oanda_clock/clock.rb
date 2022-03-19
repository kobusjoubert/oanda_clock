include Clockwork

handler do |job|
  $logger.info "STARTED #{job}"

  case job
  when 'indicator_clock_scheduler'
    scheduler = OandaService::IndicatorClockScheduler.new

    if ENV['APP_ENV'] == 'development'
      scheduler.run_indicator_updates_in_development
    else
      scheduler.run_indicator_updates_in_production
      scheduler.run_indicator_updates_in_staging
    end
  when 'strategy_clock_scheduler'
    scheduler = OandaWorker::StrategyClockScheduler.new

    if ENV['APP_ENV'] == 'development'
      scheduler.loop_over_accounts_in_development
    else
      scheduler.loop_over_accounts_in_production
      scheduler.loop_over_accounts_in_staging
    end
  when 'strategy_clock_scheduler_staging_only'
    scheduler = OandaWorker::StrategyClockScheduler.new
    scheduler.loop_over_accounts_in_staging
  when 'strategy_clock_scheduler_production_only'
    scheduler = OandaWorker::StrategyClockScheduler.new
    scheduler.loop_over_accounts_in_production
  when 'data_clock_scheduler'
    unless ENV['APP_ENV'] == 'development'
      scheduler = OandaData::DataClockScheduler.new
      scheduler.run_data_updates
    end
  end

  $logger.info "FINISHED #{job}"
end

# every(1.minute, 'indicator_clock_scheduler')

# NOTE: When setting to lower than 1.minute, search everywhere in oanda_worker for 60 and update accordingly! Not sure if this applies anymore?
# StrategyRunAllWorker timeout_job_after value should not be greater than the strategy_clock_scheduler interval. The workers could fall behind!
every(30.seconds, 'strategy_clock_scheduler')
# every(30.seconds, 'strategy_clock_scheduler_staging_only')
# every(30.seconds, 'strategy_clock_scheduler_production_only')

# every(1.day, 'data_clock_scheduler', at: '00:10')
