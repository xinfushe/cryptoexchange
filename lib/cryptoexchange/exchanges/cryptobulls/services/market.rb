module Cryptoexchange::Exchanges
  module Cryptobulls
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            false
          end
        end

        def fetch
          output = super(ticker_url)
          adapt_all(output)
        end

        def ticker_url
          "#{Cryptoexchange::Exchanges::Cryptobulls::Market::API_URL}/ticker"
        end

        def adapt_all(output)
          output.map do |pair, ticker|
            target, base = pair.split("_")

            market_pair = Cryptoexchange::Models::MarketPair.new(
              base:   base,
              target: target,
              market: Cryptobulls::Market::NAME
            )
            adapt(ticker, market_pair)
          end
        end

        def adapt(output, market_pair)
          ticker           = Cryptoexchange::Models::Ticker.new
          ticker.base      = market_pair.base
          ticker.target    = market_pair.target
          ticker.market    = Cryptobulls::Market::NAME
          ticker.last      = NumericHelper.to_d(output['last_price'])
          ticker.ask       = NumericHelper.to_d(output['lowest_ask'])
          ticker.bid       = NumericHelper.to_d(output['highest_bid'])
          ticker.change    = NumericHelper.to_d(output['price_change_24h'])
          ticker.volume    = NumericHelper.to_d(HashHelper.dig(output, 'volume', 'btc_trade'))
          ticker.timestamp = Time.now.to_i
          ticker.payload   = output
          ticker
        end
      end
    end
  end
end
