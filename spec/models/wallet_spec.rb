require 'rails_helper'

RSpec.describe Wallet, type: :model do
   let!(:user) do
    User.create!(
      username: "testuser",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Test",
      last_name: "User",
      broker_status: "broker_approved"
    )
  end

   let!(:wallet) do
  Wallet.where(user: user).destroy_all
  Wallet.create!(user: user, balance: 1000)
end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:trade_logs).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:balance) }
    it { should validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
    it { should validate_uniqueness_of(:user_id) }
    it { should validate_presence_of(:user_id) }
  end

  describe "#can_withdraw?" do
    it "returns true if balance is sufficient" do
      expect(wallet.can_withdraw?(500)).to be true
    end

    it "returns false if balance is insufficient" do
      expect(wallet.can_withdraw?(1500)).to be false
    end
  end

  describe "#deposit" do
    it "increases balance with valid amount" do
      expect { wallet.deposit(200) }.to change { wallet.reload.balance }.by(200)
    end

    it "returns false for non-positive amount" do
      expect(wallet.deposit(0)).to be false
      expect(wallet.deposit(-100)).to be false
    end
  end

  describe "#withdraw" do
    it "decreases balance with valid amount" do
      expect { wallet.withdraw(300) }.to change { wallet.reload.balance }.by(-300)
    end

    it "returns false if amount exceeds balance" do
      expect(wallet.withdraw(2000)).to be false
    end
  end

  describe "#sufficient_funds_for_purchase?" do
    it "returns true if balance covers total cost" do
      expect(wallet.sufficient_funds_for_purchase?(800)).to be true
    end

    it "returns false if balance is insufficient" do
      expect(wallet.sufficient_funds_for_purchase?(1200)).to be false
    end
  end

 describe "#trading_volume" do
  before do
    TradeLog.create!(wallet: wallet, user: user, transaction_type: "buy", amount: 100, quantity: 1)
    TradeLog.create!(wallet: wallet, user: user, transaction_type: "sell", amount: 200, quantity: 1)
    TradeLog.create!(wallet: wallet, user: user, transaction_type: "deposit", amount: 300, quantity: 1)
  end

  it "sums only buy and sell amounts" do
    expect(wallet.trading_volume).to eq(300)
  end
end

 describe "#total_deposits" do
  before do
    TradeLog.create!(wallet: wallet, user: user, transaction_type: "deposit", amount: 400, quantity: 1)
    TradeLog.create!(wallet: wallet, user: user, transaction_type: "deposit", amount: 100, quantity: 1)
    TradeLog.create!(wallet: wallet, user: user, transaction_type: "buy", amount: 50, quantity: 1)
  end

  it "sums only deposit amounts" do
    expect(wallet.total_deposits).to eq(500)
  end
end
end
