require 'rails_helper'

RSpec.describe TradeLog, type: :model do
  let(:user) do
    User.create!(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  let(:wallet) do
    Wallet.create!(
      user: user,
      balance: 1000
    )
  end

  let(:stock) do
    Stock.create!(
      symbol: "AAPL",
      name: "Apple Inc."
    )
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:stock).optional }
    it { is_expected.to belong_to(:wallet).optional }
  end

  describe 'validations' do
    it 'requires transaction_type to be present and valid' do
      log = TradeLog.new(transaction_type: nil, amount: 100, quantity: 1, user: user)
      expect(log).not_to be_valid
      expect(log.errors[:transaction_type]).to include("can't be blank")
    end

    it 'requires amount to be present and greater than 0' do
      log = TradeLog.new(transaction_type: 'buy', amount: 0, quantity: 1, user: user)
      expect(log).not_to be_valid
      expect(log.errors[:amount]).to include("must be greater than 0")
    end

    context 'when transaction_type is buy or sell' do
      it 'requires quantity > 0' do
        log = described_class.new(transaction_type: 'buy', amount: 100, quantity: 0, user: user)
        expect(log).not_to be_valid
        expect(log.errors[:quantity]).to include('must be greater than 0')
      end
    end

    context 'when transaction_type is deposit or withdraw' do
      it 'allows quantity to be 0 or more' do
        log = described_class.new(transaction_type: 'deposit', amount: 100, quantity: 0, user: user)
        expect(log).to be_valid
      end

      it 'defaults quantity to 0 if nil' do
        log = described_class.new(transaction_type: 'withdraw', amount: 50, user: user)
        log.valid?
        expect(log.quantity).to eq(0)
      end
    end
  end

  describe 'scopes' do
    before do
      described_class.create!(transaction_type: 'buy', amount: 100, quantity: 10, user: user)
      described_class.create!(transaction_type: 'sell', amount: 50, quantity: 5, user: user)
      described_class.create!(transaction_type: 'deposit', amount: 200, user: user)
      described_class.create!(transaction_type: 'withdraw', amount: 75, user: user)
    end

    it 'returns only buys' do
      expect(described_class.buys.count).to eq(1)
    end

    it 'returns only sells' do
      expect(described_class.sells.count).to eq(1)
    end

    it 'returns only deposits' do
      expect(described_class.deposits.count).to eq(1)
    end

    it 'returns only withdrawals' do
      expect(described_class.withdrawals.count).to eq(1)
    end

    it 'returns logs for a specific user' do
      expect(described_class.for_user(user).count).to eq(4)
    end
  end

  describe '.total_amount_by_log_type' do
    before do
      described_class.create!(transaction_type: 'buy', amount: 100, quantity: 10, user: user)
      described_class.create!(transaction_type: 'buy', amount: 50, quantity: 5, user: user)
    end

    it 'sums amounts for given type' do
      expect(described_class.total_amount_by_log_type('buy')).to eq(150)
    end
  end
end