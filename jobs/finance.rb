require 'finance-ytd'
require 'quote-only'

def cnn(symbol, friendly_name)
    f = CnnFinanceYtd.new({ :symbol => symbol, :friendly_name => friendly_name, :decimal_places => 2 })
    q = CnnQuoteOnly.new({ :symbol => symbol, :friendly_name => friendly_name, :decimal_places => 2 })
    calc_send(f.symbol, f.friendly_name, q.quote, f.ytd_return, f.symbol.upcase)
end

def cnn_market(symbol, friendly_name, moreinfo)
    f = CnnMarketFinanceYtd.new({ :symbol => symbol, :friendly_name => friendly_name, :decimal_places => 2 })
    q = CnnMarketQuoteOnly.new({ :symbol => symbol, :friendly_name => friendly_name, :decimal_places => 2 })
    calc_send(f.symbol, f.friendly_name, q.quote, f.ytd_return, moreinfo)
end

def calc_send(id, title, current, ytd_return, moreinfo)
    last = current / (1.0 + ytd_return)
    status = 'up'

    if current < last
        status = 'down'
    end

    current = ('%.2f') % current
    current = current.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    send_event(id, { title: title, current: current, last: last, moreinfo: moreinfo, status: status })
end

def do_job
    cnn('vt', 'World Stocks');

    f = ApmexGoldFinanceYtd.new({ :symbol => 'Gold', :friendly_name => 'Gold', :decimal_places => 2, :price_last_year => 1063.70 })
    q = ApmexGoldQuoteOnly.new({ :symbol => 'oz', :friendly_name => 'Gold', :decimal_places => 2 })
    calc_send(f.symbol.downcase, f.friendly_name, q.quote, f.ytd_return, 'per oz')

    f = ApmexSilverFinanceYtd.new({ :symbol => 'Silver', :friendly_name => 'Silver', :decimal_places => 2, :price_last_year => 13.92 })
    q = ApmexSilverQuoteOnly.new({ :symbol => 'oz', :friendly_name => 'Silver', :decimal_places => 2 })
    calc_send(f.symbol.downcase, f.friendly_name, q.quote, f.ytd_return, 'per oz')

    cnn('vti', 'US Stocks');
    cnn('vxus', 'Foreign Stocks');
    cnn_market('dow', 'Dow', 'DJIA');
    cnn('sgdm', 'Gold Miners');
    cnn('vglt', 'Long-Term Gov');

    f = BloombergFinanceYtd.new({ :symbol => 'USGG10YR:IND', :friendly_name => '10 Year', :decimal_places => 2 })
    q = BloombergQuoteOnly.new({ :symbol => 'USGG10YR:IND', :friendly_name => '10 Year', :decimal_places => 0 })
    calc_send('USGG10YRIND', f.friendly_name, q.quote, f.ytd_return, 'Treasury')

    cnn('bwz', 'Foreign Cash');
    cnn('xbt', 'Bitcoin');
end

SCHEDULER.every '1m', :first_in => 0 do |job|
    do_job
end
