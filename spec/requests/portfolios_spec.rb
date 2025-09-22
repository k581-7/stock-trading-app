require 'rails_helper'

RSpec.describe "Portfolios", type: :request do
  let(:user) do
    User.create!(
      username: "test",
      email: "user@example.com",
      password: "password",
      password_confirmation: "password",
      role: "trader",
      approved: true
      )
  end
    let(:stock) do
      Stock.create!(
        id: 1,
        title: "sample_stock",
        buying_price: 10,
        selling_price: 20
      )
    end

      before { sign_in user }

  describe "GET /index" do
    it "shows the list of portfolios" do
      expect(response).to include("sample_stock")
    end
  end
end
