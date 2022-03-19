module OandaService
  class IndicatorClockScheduler
    def run_indicator_updates_in_production
      $logger.info 'RUNNING PRODUCTION indicator_clock_scheduler indicator updates'
      IndicatorClock.new(environment: 'production').run_indicator_updates
    end

    def run_indicator_updates_in_staging
      $logger.info 'RUNNING STAGING indicator_clock_scheduler indicator updates'
      IndicatorClock.new(environment: 'staging').run_indicator_updates
    end

    def run_indicator_updates_in_development
      $logger.info 'RUNNING DEVELOPMENT indicator_clock_scheduler indicator updates'
      IndicatorClock.new(environment: 'development').run_indicator_updates
    end
  end
end
