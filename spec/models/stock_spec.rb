require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      stock = Stock.new(title: "Apple", buying_price: 100.0, selling_price: 120.0)
      expect(stock).to be_valid
    end

    it 'is invalid without title' do
      stock = Stock.new(buying_price: 100.0, selling_price: 120.0)
      expect(stock).to_not be_valid
    end

    it 'is invalid with negative buying_price' do
      stock = Stock.new(title: "Apple", buying_price: -10.0, selling_price: 120.0)
      expect(stock).to_not be_valid
    end

    it 'is invalid with negative selling_price' do
      stock = Stock.new(title: "Apple", buying_price: 100.0, selling_price: -10.0)
      expect(stock).to_not be_valid
    end
  end

  describe '#profit_margin' do
    let(:stock) { Stock.create!(title: "Apple", buying_price: 100.0, selling_price: 120.0) }

    it 'calculates profit margin correctly' do
      expect(stock.profit_margin).to eq(20.0)
    end
  end
end
