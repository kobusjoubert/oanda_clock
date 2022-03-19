class DataClock
  GRANULARITIES = ['M1', 'M5', 'M10', 'H1'].freeze
  INSTRUMENTS   = {
    'AUD_JPY'    => [GRANULARITIES[0]],
    'AUD_CAD'    => [GRANULARITIES[0]],
    'CORN_USD'   => [GRANULARITIES[0]],
    'DE30_EUR'   => [GRANULARITIES[0]],
    'EU50_EUR'   => [GRANULARITIES[0]],
    'EUR_AUD'    => [GRANULARITIES[0]],
    'EUR_GBP'    => [GRANULARITIES[0]],
    'EUR_USD'    => [GRANULARITIES[0]],
    'FR40_EUR'   => [GRANULARITIES[0]],
    'GBP_USD'    => [GRANULARITIES[0]],
    'GBP_JPY'    => [GRANULARITIES[0]],
    'HK33_HKD'   => [GRANULARITIES[0]],
    'JP225_USD'  => [GRANULARITIES[0]],
    'NATGAS_USD' => [GRANULARITIES[0]],
    'NL25_EUR'   => [GRANULARITIES[0]],
    'SG30_SGD'   => [GRANULARITIES[0]],
    'SOYBN_USD'  => [GRANULARITIES[0]],
    'SUGAR_USD'  => [GRANULARITIES[0]],
    'UK100_GBP'  => [GRANULARITIES[0]],
    'US30_USD'   => [GRANULARITIES[0]],
    'USD_JPY'    => [GRANULARITIES[0]],
    'WHEAT_USD'  => [GRANULARITIES[0]],
    'WTICO_USD'  => [GRANULARITIES[0]]
  }.freeze

  class << self
    def run_data_updates
      data = { action: 'run_data_updates', instruments: INSTRUMENTS }

      for i in 1..30
        $rabbitmq_exchange_production.publish(data.merge(back: i).to_json, routing_key: 'qd_data_run')
        $logger.info "PUBLISHED to qd_data_run. back: #{i}, instruments: #{INSTRUMENTS.keys}"
      end
    end
  end
end
