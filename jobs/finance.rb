require 'finance-ytd'
require 'quote-only'

def cnn_etf(symbol, friendly_name)
	f = CnnEtfFinanceYtd.new({ :symbol => symbol, :friendly_name => friendly_name, :decimal_places => 2 })
	q = CnnQuoteOnly.new({ :symbol => symbol, :friendly_name => friendly_name, :decimal_places => 2 })
	calc_send(f.symbol, f.friendly_name, q.quote, f.ytd_return, f.symbol.upcase)
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
	cnn_etf('vt', 'World Stocks');
	
	f = ApmexGoldFinanceYtd.new({ :symbol => 'Gold', :friendly_name => 'Gold', :decimal_places => 2, :price_last_year => 1183.90 })
	q = ApmexGoldQuoteOnly.new({ :symbol => 'oz', :friendly_name => 'Gold', :decimal_places => 2 })
	calc_send(f.symbol.downcase, f.friendly_name, q.quote, f.ytd_return, f.symbol)
	
	f = ApmexSilverFinanceYtd.new({ :symbol => 'Silver', :friendly_name => 'Silver', :decimal_places => 2, :price_last_year => 15.56 })	
	q = ApmexSilverQuoteOnly.new({ :symbol => 'oz', :friendly_name => 'Silver', :decimal_places => 2 })
	calc_send(f.symbol.downcase, f.friendly_name, q.quote, f.ytd_return, f.symbol)
	
	cnn_etf('vti', 'US Stocks');	
	cnn_etf('vxus', 'Foreign Stocks');
	cnn_etf('sgdm', 'Gold Miners');
	cnn_etf('bwz', 'Foreign Cash');
	cnn_etf('xbt', 'Bitcoin');
end

SCHEDULER.in '1' do |job|
	do_job
end

SCHEDULER.cron '0 8-15 * * *', allow_overlapping: false do |job|
	do_job
end
