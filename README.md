# OandaClock

Executes the running [Oanda Worker](https://github.com/kobusjoubert/oanda_worker) strategies every 30 seconds.

Only the strategies that was started in the [Oanda Trader](https://github.com/kobusjoubert/oanda_trader) user interface will be executed and paused strategies will be skipped until resumed again from the user interface.

## Usage

### Development

Start the service

    APP_ENV=development clockwork lib/oanda_clock.rb

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kobusjoubert/oanda_clock.
