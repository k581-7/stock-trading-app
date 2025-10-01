require "rails_helper"

RSpec.describe "TradeLogs", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user1) do
    User.create!(
      email: "user1@example.com",
      username: "user1",
      password: "Password1!",
      confirmed_at: Time.current,
      approved: true
    )
  end

  let(:user2) do
    User.create!(
      email: "user2@example.com",
      username: "user2",
      password: "Password1!",
      confirmed_at: Time.current,
      approved: true
    )
  end

  it "shows only the current user's trade logs" do
    TradeLog.create!(user: user1, transaction_type: "buy", quantity: 1, amount: 100)
    TradeLog.create!(user: user2, transaction_type: "sell", quantity: 2, amount: 200)

    sign_in user1
    get trade_logs_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Buy")
    expect(response.body).not_to include("Sell")
  end
end
