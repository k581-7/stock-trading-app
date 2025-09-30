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
      name: "sample_stock",
      buying_price: 10,
      selling_price: 20
    )
  end

  let!(:portfolio) do
    Portfolio.create!(
      user: user,
      stock: stock,
      quantity: 5
    )
  end

  before { sign_in user }

  describe "GET /index" do
    it "shows the list of portfolios" do
      get portfolios_path   # 🔑 importante: gawin yung request

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("sample_stock") # response.body ang i-check, hindi response object mismo
    end
  end
end
