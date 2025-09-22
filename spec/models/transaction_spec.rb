require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      transaction = Transaction.new(type: 'buy', quantity: 10, amount: 1000)
      expect(transaction).to be_valid
    end

    it 'is invalid without type' do
      transaction = Transaction.new(quantity: 10, amount: 1000)
      expect(transaction).to_not be_valid
      expect(transaction.errors[:type]).to include("can't be blank")
    end

    it 'is invalid with invalid type' do
      transaction = Transaction.new(type: 'invalid', quantity: 10, amount: 1000)
      expect(transaction).to_not be_valid
      expect(transaction.errors[:type]).to include("is not included in the list")
    end

    it 'is invalid with zero quantity' do
      transaction = Transaction.new(type: 'buy', quantity: 0, amount: 1000)
      expect(transaction).to_not be_valid
      expect(transaction.errors[:quantity]).to include("must be greater than 0")
    end

    it 'is invalid with zero amount' do
      transaction = Transaction.new(type: 'buy', quantity: 10, amount: 0)
      expect(transaction).to_not be_valid
      expect(transaction.errors[:amount]).to include("must be greater than 0")
    end
  end

  describe 'scopes' do
    before do
      Transaction.create!(type: 'buy', quantity: 10, amount: 1000)
      Transaction.create!(type: 'sell', quantity: 5, amount: 600)
    end

    it 'filters by transaction type' do
      expect(Transaction.buy_transactions.count).to eq(1)
      expect(Transaction.sell_transactions.count).to eq(1)
    end
  end

  describe '.total_amount_by_type' do
    before do
      Transaction.create!(type: 'buy', quantity: 10, amount: 1000)
      Transaction.create!(type: 'buy', quantity: 20, amount: 2000)
    end

    it 'calculates total amount correctly' do
      expect(Transaction.total_amount_by_type('buy')).to eq(3000)
    end
  end
end
