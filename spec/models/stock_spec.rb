require 'rails_helper'

RSpec.describe Stock, type: :model do
  let(:portfolio) { Portfolio.create!(quantity: 10) }

  context "validations" do
    it "is valid with valid attributes" do
      stock = Stock.new(
        title: "AAPL",
        buying_price: 100,
        selling_price: 150,
        portfolio: portfolio
      )
      expect(stock).to be_valid
    end

    it "is not valid without a title" do
      stock = Stock.new(
        title: nil,
        buying_price: 100,
        selling_price: 150,
        portfolio: portfolio
      )
      expect(stock).not_to be_valid
    end

    it "is not valid with negative buying_price" do
      stock = Stock.new(
        title: "AAPL",
        buying_price: -10,
        selling_price: 150,
        portfolio: portfolio
      )
      expect(stock).not_to be_valid
    end

    it "is not valid with negative selling_price" do
      stock = Stock.new(
        title: "AAPL",
        buying_price: 100,
        selling_price: -50,
        portfolio: portfolio
      )
      expect(stock).not_to be_valid
    end
  end

  context "associations" do
    it "belongs to a portfolio" do
      stock = Stock.create!(
        title: "TSLA",
        buying_price: 200,
        selling_price: 250,
        portfolio: portfolio
      )
      expect(stock.portfolio).to eq(portfolio)
    end
  end
end