puts "Seeding admin user..."

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.username = "admin"
  u.password = "Password1!"
  u.password_confirmation = "Password1!"
  u.role = :admin
  u.confirmed_at = Time.current  # skip confirmable for seed
  u.approval_date = Time.current   # mark approved immediately
end

puts "Admin user ready: #{admin.email} / Password1!"
if Stock.count == 0
  puts "Seeding sample stocks..."
client = FinnhubRuby::DefaultApi.new
  symbols = ["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "NVDA", "META", "JPM", "V", "MA"]
  symbols.each do |symbol|
    begin
      quote = client.quote(symbol)
      profile = client.company_profile2({ symbol: symbol })     

      Stock.create!(
        symbol: symbol,
        name: profile['name'],
        current_price: quote['c'],
        price_change: quote['d'],
        percent_change: quote['dp'],
        volume: quote['v'],
        market_open: quote['t'] != 0, # crude check: if timestamp is 0, market likely closed
        last_updated_at: Time.at(quote['t'])
      )
    rescue => e
      puts "Error seeding #{symbol}: #{e.message}"
    end
  end
end
