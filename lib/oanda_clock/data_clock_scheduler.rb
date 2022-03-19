module OandaData
  class DataClockScheduler
    def run_data_updates
      $logger.info 'RUNNING data_clock_scheduler data updates'
      DataClock.run_data_updates if Time.now.utc.sunday?
    end
  end
end
