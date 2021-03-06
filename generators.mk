tools_root         := ./tools
assets_root        := ./assets
markets_root       := ./markets/market
currencies_root    := ./currencies
markets            := $(shell find $(markets_root)/* -maxdepth 1 -type d | xargs basename)

all_currencies     := $(currencies_root)/currencies.json
markets_currencies := $(foreach market,$(markets),$(markets_root)/$(market)/currencies.json)

.PHONY: $(all_currencies)
$(all_currencies):
	# XXX: Not all fiat currencies could be traded on all markets, you should check by hands!
	{                                                                                    \
		set -e;                                                                      \
		echo '{"name": "china-yan",            "symbol": "CNY", "volume": 9999999}'; \
		echo '{"name": "japanese-yen",         "symbol": "JPY", "volume": 9999999}'; \
		echo '{"name": "russian-ruble",        "symbol": "RUB", "volume": 9999999}'; \
		echo '{"name": "united-states-dollar", "symbol": "USD", "volume": 9999999}'; \
		echo '{"name": "euro",                 "symbol": "EUR", "volume": 9999999}'; \
		echo '{"name": "canadian-dollar",      "symbol": "CAD", "volume": 9999999}'; \
		go run $(tools_root)/coinmarketcap/coinmarketcap.go all;                     \
	} | $(tools_root)/postprocess-currencies --verbose | jq . > $@

.PHONY: $(markets_currencies)
$(markets_currencies):
	# XXX: Not all fiat currencies could be traded on all markets, you should check by hands!
	{                                                                                    \
		set -e;                                                                      \
		echo '{"name": "china-yan",            "symbol": "CNY", "volume": 9999999}'; \
		echo '{"name": "japanese-yen",         "symbol": "JPY", "volume": 9999999}'; \
		echo '{"name": "russian-ruble",        "symbol": "RUB", "volume": 9999999}'; \
		echo '{"name": "united-states-dollar", "symbol": "USD", "volume": 9999999}'; \
		echo '{"name": "euro",                 "symbol": "EUR", "volume": 9999999}'; \
		echo '{"name": "canadian-dollar",      "symbol": "CAD", "volume": 9999999}'; \
		go run $(tools_root)/coinmarketcap/coinmarketcap.go                          \
			exchanges --exchange=$(shell basename $(@:%/currencies.json=%));     \
	} | $(tools_root)/postprocess-currencies --verbose | jq . > $@

.PHONY: generate
# Autodownload was disabled because coinmarketcap
# does not report market specific pair names now.
# Was: https://web.archive.org/web/20171122224625/https://coinmarketcap.com/exchanges/bitfinex/
# Now: https://coinmarketcap.com/exchanges/bitfinex/
#generate:: $(all_currencies)
#generate:: $(markets_currencies)
generate::
	go-bindata                                                      \
		-o        $(assets_root)/assets.go                      \
		--pkg     assets                                        \
		--ignore '.*\.go'                                       \
		--nometadata                                            \
		$(foreach market,$(markets),$(markets_root)/$(market)/) \
		$(currencies_root)/
	go fmt $(assets_root)/assets.go
