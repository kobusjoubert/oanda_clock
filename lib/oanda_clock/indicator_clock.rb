class IndicatorClock
  REQUIRED_ATTRIBUTES = [:environment].freeze

  # Instruments:
  #
  #   Commodities:
  #   NATGAS_USD, SUGAR_USD, WTICO_USD, CORN_USD, SOYBN_USD, WHEAT_USD
  #
  #   Indices:
  #   EU50_EUR, FR40_EUR, HK33_HKD, JP225_USD, NL25_EUR, SG30_SGD, UK100_GBP, US30_USD
  #
  #   Forex:
  #   AUD_CAD, AUD_CHF, AUD_JPY, AUD_NZD, AUD_USD, CAD_CHF, CAD_JPY, CHF_JPY, EUR_AUD, EUR_CAD, EUR_CHF, EUR_GBP, EUR_JPY, EUR_NZD, EUR_USD, GBP_AUD, GBP_CHF, GBP_JPY GBP_USD, HKD_JPY, NZD_JPY, NZD_USD, USD_CHF, USD_JPY
  POINT_AND_FIGURE_SETTINGS = {
    'D_5_3_CL'   => { granularity: 'D', box_size: 5, reversal_amount: 3, high_low_close: 'close' },
    'D_10_3_CL'  => { granularity: 'D', box_size: 10, reversal_amount: 3, high_low_close: 'close' },
    'H1_5_3_HL'  => { granularity: 'H1', box_size: 5, reversal_amount: 3, high_low_close: 'high_low' },
    'H1_10_3_HL' => { granularity: 'H1', box_size: 10, reversal_amount: 3, high_low_close: 'high_low' }
  }.freeze

  # NOTE:
  #
  #   Only 16 settings can be processes concurrently. (WEB_CONCURRENCY = 2, RAILS_MAX_THREADS = 8)
  #   The remainder will be processed immediately when new threads become available from OandaInstrument.
  #   OandaInstrument only has 20 DB connections available on Hobby tiers.
  #   We need to leave a few DB connections available for rails console.
  INDICATORS = {
    point_and_figure: {
      'US30_USD' => [POINT_AND_FIGURE_SETTINGS['D_10_3_CL'], POINT_AND_FIGURE_SETTINGS['H1_10_3_HL']]
    }
  }.freeze

  attr_accessor :environment

  def initialize(options = {})
    missing_attributes = REQUIRED_ATTRIBUTES - options.keys
    raise ArgumentError, "The #{missing_attributes} attributes are missing" unless missing_attributes.empty?

    options.each do |key, value|
      self.send("#{key}=", value) if self.respond_to?("#{key}=")
    end
  end

  def run_indicator_updates
    INDICATORS.each do |indicator, instruments|
      data = { action: 'update_points', indicator: indicator }

      instruments.each do |instrument, settings|
        settings.each do |options|
          data.merge!(options: options.merge(instrument: instrument, plot_to_sheet: true))

          case environment
          when 'production'
            $rabbitmq_exchange_production.publish(data.to_json, routing_key: 'qs_indicator_update')
            $logger.info "PUBLISHED PRODUCTION to qs_indicator_update. instrument: #{instrument}, indicator: #{indicator}, options: #{options}"
          when 'staging'
            $rabbitmq_exchange_staging.publish(data.to_json, routing_key: 'qs_indicator_update')
            $logger.info "PUBLISHED STAGING to qs_indicator_update. instrument: #{instrument}, indicator: #{indicator}, options: #{options}"
          when 'development'
            $rabbitmq_exchange_development.publish(data.to_json, routing_key: 'qs_indicator_update')
            $logger.info "PUBLISHED DEVELOPMENT to qs_indicator_update. instrument: #{instrument}, indicator: #{indicator}, options: #{options}"
          end
        end
      end
    end
  end
end
