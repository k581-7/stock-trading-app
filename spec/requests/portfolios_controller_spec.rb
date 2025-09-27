require 'rails_helper'

RSpec.describe "Portfolios", type: :request do
  include Devise::Test::IntegrationHelpers
  let!(:user) { User.create!(username: "karla", email: "user@example.com", password: "password123") }
  let!(:other_user) { User.create!(username: "otherkarla", email: "other@example.com", password: "password123") }
  let!(:stock) { Stock.create!(name: "Apple Inc.", symbol: "AAPL", current_price: 175.25) }

  let(:valid_attributes) { { stock_id: stock.id, quantity: 10 } }
  let(:invalid_attributes) { { stock_id: nil, quantity: nil } }

  before { user.confirm; sign_in user }

  describe "GET /portfolios" do
    let!(:own_portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 5) }
    let!(:other_portfolio) { Portfolio.create!(user: other_user, stock: stock, quantity: 15) }

    it "shows only current_user's portfolios" do
      get portfolios_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(own_portfolio.quantity.to_s)
      expect(response.body).not_to include(other_portfolio.quantity.to_s)
    end
  end

  describe "GET /portfolios/:id" do
    context "when accessing own portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      it "renders the show page" do
        get portfolio_path(portfolio)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(portfolio.stock.symbol)
        expect(response.body).to include(portfolio.quantity.to_s)
      end
    end

    context "when accessing another user's portfolio" do
      let!(:portfolio) { Portfolio.create!(user: other_user, stock: stock, quantity: 10) }

      it "redirects with authorization error" do
        get portfolio_path(portfolio)
        expect(response).to redirect_to(portfolios_path)
        follow_redirect!
        expect(response.body).to include("Not authorized")
      end
    end
  end

  describe "POST /portfolios" do
    it "creates a portfolio for the current user" do
      expect {
        post portfolios_path, params: { portfolio: valid_attributes }
      }.to change { user.portfolios.count }.by(1)
      expect(response).to redirect_to(portfolio_path(Portfolio.last))
    end

    it "renders errors on failure" do
      post portfolios_path, params: { portfolio: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to match(/error|can't be blank/i)
    end
  end

  describe "PATCH /portfolios/:id" do
    context "own portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      it "updates quantity" do
        patch portfolio_path(portfolio), params: { portfolio: { quantity: 20 } }
        expect(portfolio.reload.quantity).to eq(20)
        expect(response).to redirect_to(portfolio_path(portfolio))
      end
    end

    context "another user's portfolio" do
      let!(:portfolio) { Portfolio.create!(user: other_user, stock: stock, quantity: 10) }

      it "blocks update" do
        patch portfolio_path(portfolio), params: { portfolio: { quantity: 20 } }
        expect(response).to redirect_to(portfolios_path)
      end
    end
  end

  describe "DELETE /portfolios/:id" do
    context "own portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      it "deletes the portfolio" do
        expect {
          delete portfolio_path(portfolio)
        }.to change { user.portfolios.count }.by(-1)
        expect(response).to redirect_to(portfolios_path)
      end
    end

    context "another user's portfolio" do
      let!(:portfolio) { Portfolio.create!(user: other_user, stock: stock, quantity: 10) }

      it "blocks deletion" do
        delete portfolio_path(portfolio)
        expect(response).to redirect_to(portfolios_path)
        follow_redirect!
        expect(response.body).to include("Not authorized") 
      end
    end
  end
end
