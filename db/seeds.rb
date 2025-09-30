puts "Seeding admin user..."

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.username = "admin"
  u.password = "Password1!"
  u.password_confirmation = "Password1!"
  u.role = :admin
  u.confirmed_at = Time.current
  u.approval_date = Time.current
end

puts "Admin ready: #{admin.email} / Password1!"

puts "Seeding stocks and portfolios..."

client = FinnhubRuby::DefaultApi.new
symbols = ["AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "NVDA", "META", "JPM", "V", "MA", "XOM", "UNH"]

symbols.each do |symbol|
  next if Stock.exists?(symbol: symbol)

  begin
    quote = client.quote(symbol)
    profile = client.company_profile2({ symbol: symbol })

    stock = Stock.create!(
      symbol: symbol,
      name: profile['name'],
      current_price: quote['c'],
      price_change: quote['d'],
      percent_change: quote['dp'],
      volume: quote['v'],
      market_open: quote['t'].to_i != 0,
      last_updated_at: quote['t'].to_i > 0 ? Time.at(quote['t']) : Time.current
    )

    puts "Stock seeded: #{symbol} - #{stock.name}"

    # Create portfolio entry for admin
    Portfolio.find_or_create_by!(user: admin, stock: stock) do |p|
      p.quantity = rand(5..20)
    end

    puts "Portfolio added for admin: #{symbol}"

  rescue => e
    puts "Error seeding #{symbol}: #{e.message}"
  end
end

puts "Seeding complete!"