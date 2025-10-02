require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  let!(:user)  { User.create!(username: "trader1", email: "t1@example.com", password: "Password1!", confirmed_at: Time.current, role: :broker) }
  let!(:stock) { Stock.create!(symbol: "AAPL", name: "Apple Inc.", current_price: 150.0) }

  it "requires the presence of a symbol for stock" do
    expect(Stock.new(name: "No Symbol", current_price: 100.0)).not_to be_valid
  end

  describe "validations" do
    it "is valid with user, stock, and quantity > 0" do
      p = Portfolio.new(user: user, stock: stock, quantity: 5)
      expect(p).to be_valid
    end

    it "requires quantity to be greater than 0" do
      p = Portfolio.new(user: user, stock: stock, quantity: 0)
      expect(p).not_to be_valid
      expect(p.errors[:quantity]).to include("must be greater than 0")
    end

    it "requires uniqueness of user+stock" do
      Portfolio.create!(user: user, stock: stock, quantity: 1)
      dup = Portfolio.new(user: user, stock: stock, quantity: 2)
      expect(dup).not_to be_valid
      expect(dup.errors[:user_id]).to include("can only have one portfolio per stock")
    end
  end

  describe "calculations" do
    let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

    it "calculates total value using current price" do
      expect(portfolio.total_buying_value).to eq(10 * 150.0)
    end
  end
end
