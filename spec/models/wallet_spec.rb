# spec/models/wallet_spec.rb
require "rails_helper"

RSpec.describe Wallet, type: :model do
  let!(:user) do
    User.create!(
      username: "trader1",
      email: "trader1@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      confirmed_at: Time.current,
      role: :broker
    )
  end

  describe "validations" do
    it "is valid with a user and non-negative balance (uses auto-created wallet)" do
      user.wallet.update!(balance: 100)  # ensure a valid non-negative balance
      expect(user.wallet).to be_valid
    end

    it "requires balance to be >= 0" do
      w = user.wallet
      w.balance = -5
      expect(w).not_to be_valid
      expect(w.errors[:balance]).to include("must be greater than or equal to 0")
      w.balance = 0
      expect(w).to be_valid
    end

    it "requires a user" do
      wallet = Wallet.new(balance: 10)  # no user
      expect(wallet).not_to be_valid
      expect(wallet.errors[:user]).to be_present
    end

    it "requires unique wallet per user" do
      # user already has a wallet via after_create :ensure_wallet!
      dup = Wallet.new(user: user, balance: 20)
      expect(dup).not_to be_valid
      expect(dup.errors[:user_id]).to include("has already been taken")
    end
  end

  describe "instance methods" do
    let!(:wallet) { user.wallet.tap { |w| w.update!(balance: 100) } }

    it "#can_withdraw? returns true only if balance >= amount" do
      expect(wallet.can_withdraw?(50)).to be true
      expect(wallet.can_withdraw?(100)).to be true
      expect(wallet.can_withdraw?(100.01)).to be false
      expect(wallet.can_withdraw?(0)).to be true
    end

    it "#deposit increases balance for positive amounts and persists" do
      expect(wallet.deposit(25)).to be true
      expect(wallet.reload.balance.to_d).to eq(125.to_d)
    end

    it "#deposit rejects zero or negative amounts" do
      expect(wallet.deposit(0)).to be false
      expect(wallet.deposit(-10)).to be false
      expect(wallet.reload.balance.to_d).to eq(100.to_d)
    end

    it "#withdraw decreases balance when sufficient and persists" do
      expect(wallet.withdraw(30)).to be true
      expect(wallet.reload.balance.to_d).to eq(70.to_d)
    end

    it "#withdraw returns false and does not change balance when insufficient" do
      expect(wallet.withdraw(200)).to be false
      expect(wallet.reload.balance.to_d).to eq(100.to_d)
    end

    it "#sufficient_funds_for_purchase? mirrors balance checks" do
      expect(wallet.sufficient_funds_for_purchase?(50)).to be true
      expect(wallet.sufficient_funds_for_purchase?(200)).to be false
    end

    context "with decimal amounts" do
      it "handles decimal math deterministically" do
        wallet.update!(balance: 0)
        expect(wallet.deposit(0.10)).to be true
        expect(wallet.deposit(0.20)).to be true
        # compare as BigDecimal to avoid float precision surprises
        expect(wallet.reload.balance.to_d).to eq(BigDecimal("0.30"))
      end

      it "withdraws exact decimal amounts if available" do
        wallet.update!(balance: BigDecimal("10.50"))
        expect(wallet.withdraw(0.50)).to be true
        expect(wallet.reload.balance.to_d).to eq(BigDecimal("10.00"))
      end
    end
  end
end
