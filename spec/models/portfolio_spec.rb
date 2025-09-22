require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  let!(:user)  { User.create!(username: "trader1", email: "t1@example.com", password: "Password1!", confirmed_at: Time.current, role: :broker) }
  let!(:stock) { Stock.create!(title: "AAPL", buying_price: 100.0, selling_price: 120.0) }

  # -----------------
  # STOCK validation
  # -----------------
  it "requires the presence of a title for stock" do
    expect(Stock.new(buying_price: 50.0, selling_price: 60.0)).not_to be_valid
  end

  # -----------------
  # PORTFOLIO validations
  # -----------------
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

  # -----------------
  # PORTFOLIO methods
  # -----------------
  describe "calculations" do
    let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

    it "calculates total buying value" do
      expect(portfolio.total_buying_value).to eq(10 * 100.0)
    end

    it "calculates total selling value" do
      expect(portfolio.total_selling_value).to eq(10 * 120.0)
    end

    it "calculates profit/loss" do
      expect(portfolio.profit_loss).to eq((10 * 120.0) - (10 * 100.0))
    end

    it "calculates profit/loss percentage" do
      expected_percentage = (((10 * 120.0) - (10 * 100.0)) / (10 * 100.0)) * 100
      expect(portfolio.profit_loss_percentage).to eq(expected_percentage.round(2))
    end
  end
end
