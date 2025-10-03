require 'rails_helper'

RSpec.describe TradeLog, type: :model do
  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, user: user, balance: 1000) }
  let(:stock) { create(:stock, current_price: 100) }

  describe "validations" do
    it "is valid with buy type, amount, quantity, user, stock, wallet" do
      log = TradeLog.new(
        user: user,
        stock: stock,
        wallet: wallet,
        transaction_type: "buy",
        amount: 500,
        quantity: 5
      )
      expect(log).to be_valid
    end

    it "is invalid without transaction_type" do
      log = TradeLog.new(user: user, amount: 100, quantity: 1)
      expect(log).not_to be_valid
      expect(log.errors[:transaction_type]).to include("can't be blank")
    end

    it "is invalid with unsupported transaction_type" do
      log = TradeLog.new(user: user, transaction_type: "invalid", amount: 100, quantity: 1)
      expect(log).not_to be_valid
      expect(log.errors[:transaction_type]).to include("is not included in the list")
    end

    it "requires quantity > 0 for buy/sell" do
      log = TradeLog.new(user: user, transaction_type: "buy", amount: 100, quantity: 0)
      expect(log).not_to be_valid
      expect(log.errors[:quantity]).to include("must be greater than 0")
    end

    it "defaults quantity to 0 for deposit/withdraw if nil" do
      log = TradeLog.new(user: user, transaction_type: "deposit", amount: 100)
      log.valid?
      expect(log.quantity).to eq(0)
    end

    it "requires amount > 0" do
      log = TradeLog.new(user: user, transaction_type: "buy", amount: 0, quantity: 1)
      expect(log).not_to be_valid
      expect(log.errors[:amount]).to include("must be greater than 0")
    end
  end

  describe "scopes" do
    before do
      create(:trade_log, user: user, transaction_type: "buy", amount: 100, quantity: 1)
      create(:trade_log, user: user, transaction_type: "sell", amount: 200, quantity: 2)
      create(:trade_log, user: user, transaction_type: "deposit", amount: 300)
      create(:trade_log, user: user, transaction_type: "withdraw", amount: 400)
    end

    it "returns only buys" do
      expect(TradeLog.buys.count).to eq(1)
    end

    it "returns only sells" do
      expect(TradeLog.sells.count).to eq(1)
    end

    it "returns only deposits" do
      expect(TradeLog.deposits.count).to eq(1)
    end

    it "returns only withdrawals" do
      expect(TradeLog.withdrawals.count).to eq(1)
    end

    it "returns logs for a specific user" do
      expect(TradeLog.for_user(user).count).to eq(4)
    end
  end

  describe ".total_amount_by_log_type" do
    before do
      create(:trade_log, user: user, transaction_type: "buy", amount: 100, quantity: 1)
      create(:trade_log, user: user, transaction_type: "buy", amount: 200, quantity: 2)
    end

    it "sums amount for given transaction type" do
      expect(TradeLog.total_amount_by_log_type("buy")).to eq(300)
    end
  end
end