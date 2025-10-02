require 'rails_helper'

RSpec.describe "Portfolios", type: :request do
  include Devise::Test::IntegrationHelpers  # ✅ Add this!
  
  let(:user) do
    User.create!(
      username: "test",
      email: "user@example.com",
      password: "password",
      password_confirmation: "password",
      role: :trader,
      approved: true
    )
  end

  let(:stock) do
    Stock.create!(
      symbol: "SMPL",
      name: "sample_stock",
      current_price: 10.00,
      price_change: 20.00
    )
  end

  let!(:portfolio) do
    Portfolio.create!(
      user: user,
      stock: stock,
      quantity: 5
    )
  end

  before { user.confirm; sign_in user }  # ✅ Add user.confirm!

  describe "GET /index" do
    it "shows the list of portfolios" do
      get portfolios_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("SMPL") 
    end
  end
end