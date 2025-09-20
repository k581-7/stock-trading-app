require "rails_helper"

RSpec.describe Wallet, type: :model do
  let!(:user) do
    User.create!(
      username: "trader1",
      email: "trader1@example.com",
      password: "Password1!",
      confirmed_at: Time.current,
      role: :broker
    )
  end

  describe "validations" do
    it "is valid with a user and non-negative balance" do
      wallet = Wallet.new(user: user, balance: 100)
      expect(wallet).to be_valid
    end

    it "requires balance to be >= 0" do
      wallet = Wallet.new(user: user, balance: -5)
      expect(wallet).not_to be_valid
      expect(wallet.errors[:balance]).to include("must be greater than or equal to 0")
    end

    it "requires a user" do
      wallet = Wallet.new(balance: 10)
      expect(wallet).not_to be_valid
      expect(wallet.errors[:user]).to be_present
    end

    it "requires unique wallet per user" do
      Wallet.create!(user: user, balance: 50)
      dup = Wallet.new(user: user, balance: 20)
      expect(dup).not_to be_valid
      expect(dup.errors[:user_id]).to include("has already been taken")
    end
  end

  describe "instance methods" do
    let!(:wallet) { Wallet.create!(user: user, balance: 100) }

    it "checks if it can withdraw" do
      expect(wallet.can_withdraw?(50)).to be true
      expect(wallet.can_withdraw?(200)).to be false
    end

    it "deposits positive amounts" do
      expect(wallet.deposit(25)).to be true
      expect(wallet.reload.balance).to eq(125)
    end

    it "does not deposit zero or negative amounts" do
      expect(wallet.deposit(0)).to be false
      expect(wallet.deposit(-10)).to be false
      expect(wallet.reload.balance).to eq(100)
    end

    it "withdraws when funds are sufficient" do
      expect(wallet.withdraw(30)).to be true
      expect(wallet.reload.balance).to eq(70)
    end

    it "does not withdraw when funds are insufficient" do
      expect(wallet.withdraw(200)).to be false
      expect(wallet.reload.balance).to eq(100)
    end

    it "checks sufficient_funds_for_purchase?" do
      expect(wallet.sufficient_funds_for_purchase?(50)).to be true
      expect(wallet.sufficient_funds_for_purchase?(200)).to be false
    end
  end
end
