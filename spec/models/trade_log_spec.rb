require 'rails_helper'

RSpec.describe TradeLog, transaction_type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      trade_log = TradeLog.new(transaction_type: 'buy', quantity: 10, amount: 1000)
      expect(trade_log).to be_valid
    end

    it 'is invalid without transaction_type' do
      trade_log = TradeLog.new(quantity: 10, amount: 1000)
      expect(trade_log).to_not be_valid
      expect(trade_log.errors[:transaction_type]).to include("can't be blank")
    end

    it 'is invalid with invalid transaction_type' do
      trade_log = TradeLog.new(transaction_type: 'invalid', quantity: 10, amount: 1000)
      expect(trade_log).to_not be_valid
      expect(trade_log.errors[:transaction_type]).to include("is not included in the list")
    end

    it 'is invalid with zero quantity' do
      trade_log = TradeLog.new(transaction_type: 'buy', quantity: 0, amount: 1000)
      expect(trade_log).to_not be_valid
      expect(trade_log.errors[:quantity]).to include("must be greater than 0")
    end

    it 'is invalid with zero amount' do
      trade_log = TradeLog.new(transaction_type: 'buy', quantity: 10, amount: 0)
      expect(trade_log).to_not be_valid
      expect(trade_log.errors[:amount]).to include("must be greater than 0")
    end
  end

  describe 'scopes' do
    before do
      TradeLog.create!(transaction_type: 'buy', quantity: 10, amount: 1000)
      TradeLog.create!(transaction_type: 'sell', quantity: 5, amount: 600)
    end

    it 'filters by transaction transaction_type' do
      expect(TradeLog.buys.count).to eq(1)
      expect(TradeLog.sells.count).to eq(1)
    end
  end

  describe '.total_amount_by_log_transaction_type' do
    before do
      TradeLog.create!(transaction_type: 'buy', quantity: 10, amount: 1000)
      TradeLog.create!(transaction_type: 'buy', quantity: 20, amount: 2000)
    end

    it 'calculates total amount correctly' do
      expect(TradeLog.total_amount_by_log_type('buy')).to eq(3000)
    end
  end
end