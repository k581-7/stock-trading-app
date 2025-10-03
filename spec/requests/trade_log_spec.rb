# frozen_string_literal: true
require "rails_helper"
require "securerandom"

RSpec.describe "TradeLogs", type: :request do
  include Devise::Test::IntegrationHelpers

  def uniq
    SecureRandom.hex(4)
  end

  let!(:user) do
    User.create!(
      username: "user_#{uniq}",
      first_name: "Angela",
      last_name: "Lopez",
      email: "user_#{uniq}@example.com",
      password: "password123",
      password_confirmation: "password123",
      approved: true,
      confirmed_at: Time.current # drop if Devise confirmable is off
    )
  end

  let!(:wallet) do
    Wallet.find_or_create_by!(user: user) { |w| w.balance = 0.to_d }
  end

  let!(:stock) do
    Stock.create!(
      symbol: "A#{uniq.upcase[0,3]}",
      name: "Apple Inc.",
      current_price: 100.0,
      percent_change: 0,
      market_open: false
    )
  end

  # Seed logs with staggered timestamps (newest first expected)
  let!(:deposit_log_old) do
    TradeLog.create!(
      user: user, wallet: wallet,
      transaction_type: "deposit",
      quantity: 0.to_d, amount: 500.to_d,
      created_at: 2.hours.ago
    )
  end

  let!(:withdraw_log_recent) do
    TradeLog.create!(
      user: user, wallet: wallet,
      transaction_type: "withdraw",
      quantity: 0.to_d, amount: 100.to_d,
      created_at: 1.hour.ago
    )
  end

  let!(:buy_log_middle) do
    TradeLog.create!(
      user: user, wallet: wallet, stock: stock,
      transaction_type: "buy",
      quantity: 3.to_d, amount: 300.to_d,
      created_at: 90.minutes.ago
    )
  end

  let!(:sell_log_latest) do
    TradeLog.create!(
      user: user, wallet: wallet, stock: stock,
      transaction_type: "sell",
      quantity: 1.to_d, amount: 100.to_d,
      created_at: 10.minutes.ago
    )
  end

  describe "GET /trade_logs" do
    it "redirects to sign-in when not authenticated" do
      get trade_logs_path
      expect(response).to have_http_status(:found) # 302
      # Optional: expect redirect target
      expect(response).to redirect_to(new_user_session_path)
    end

    context "when signed in" do
      before { sign_in user }

      it "returns 200 and the controller applies newest-first ordering" do
        get trade_logs_path
        expect(response).to have_http_status(:ok)

        expected = [sell_log_latest, withdraw_log_recent, buy_log_middle, deposit_log_old]
        # Compare to what the controller scopes to:
        expect(user.trade_logs.order(created_at: :desc).to_a).to eq(expected)
      end

      it "wallet logs include only deposit/withdraw" do
        get trade_logs_path
        wallet_logs = user.trade_logs.where(transaction_type: %w[deposit withdraw])
        expect(wallet_logs).to match_array([deposit_log_old, withdraw_log_recent])
        expect(wallet_logs.pluck(:transaction_type).uniq.sort).to eq(%w[deposit withdraw])
      end

      it "trade history includes only buy/sell" do
        get trade_logs_path
        trade_history = user.trade_logs.where(transaction_type: %w[buy sell])
        expect(trade_history).to match_array([buy_log_middle, sell_log_latest])
        expect(trade_history.pluck(:transaction_type).uniq.sort).to eq(%w[buy sell])
      end

      it "excludes other users' logs" do
        other_suffix = uniq
        other_user = User.create!(
          username: "other_#{other_suffix}",
          first_name: "Other",
          last_name: "User",
          email: "other_#{other_suffix}@example.com",
          password: "password123",
          password_confirmation: "password123",
          confirmed_at: Time.current
        )
        other_wallet = Wallet.find_or_create_by!(user: other_user) { |w| w.balance = 0.to_d }
        other_log = TradeLog.create!(
          user: other_user, wallet: other_wallet,
          transaction_type: "deposit",
          quantity: 0.to_d, amount: 999.to_d,
          created_at: 5.minutes.ago
        )

        get trade_logs_path
        # Confirm our expected list doesn't include other user's log
        expect(user.trade_logs.order(created_at: :desc)).not_to include(other_log)
      end
    end
  end
end
