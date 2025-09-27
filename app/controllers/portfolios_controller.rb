require 'rails_helper'

RSpec.describe "PortfoliosController", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:user) { User.create!(username: "karla", email: "user@example.com", password: "password123") }
  let!(:other_user) { User.create!(username: "otherkarla", email: "other@example.com", password: "password123") }
  let!(:stock) { Stock.create!(name: "Apple Inc.", symbol: "AAPL", current_price: 175.25) }
  let(:valid_attributes) { { stock_id: stock.id, quantity: 10 } }
  let(:invalid_attributes) { { stock_id: nil, quantity: nil } }

  describe "GET /portfolios" do
    before do
      sign_in user
      Portfolio.create!(user: user, stock: stock, quantity: 5)
      Portfolio.create!(user: other_user, stock: stock, quantity: 15)
    end

    it "shows only current_user's portfolios" do
      get portfolios_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("AAPL")
      expect(response.body).not_to include("15")
    end
  end

  describe "GET /portfolios/:id" do
    context "own portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      before { sign_in user }

      it "renders the portfolio" do
        get portfolio_path(portfolio)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("AAPL")
      end
    end

    context "another user's portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      before { sign_in other_user }

      it "redirects with authorization error" do
        get portfolio_path(portfolio)
        expect(response).to redirect_to(portfolios_path)
        follow_redirect!
        expect(response.body).to include("Not authorized")
      end
    end
  end

  describe "GET /portfolios/new" do
    before { sign_in user }

    it "renders the new form" do
      get new_portfolio_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("form")
    end
  end

  describe "POST /portfolios" do
    before { sign_in user }

    it "creates a portfolio" do
      expect {
        post portfolios_path, params: { portfolio: valid_attributes }
      }.to change { user.portfolios.count }.by(1)
      expect(response).to redirect_to(Portfolio.last)
    end

    it "renders errors on failure" do
      post portfolios_path, params: { portfolio: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to match(/can't be blank|error/i)
    end
  end

  describe "GET /portfolios/:id/edit" do
    let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

    before { sign_in user }

    it "renders the edit form" do
      get edit_portfolio_path(portfolio)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("form")
    end
  end

  describe "PATCH /portfolios/:id" do
    context "own portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      before { sign_in user }

      it "updates the portfolio" do
        patch portfolio_path(portfolio), params: { portfolio: { quantity: 20 } }
        expect(portfolio.reload.quantity).to eq(20)
        expect(response).to redirect_to(portfolio)
      end
    end

    context "another user's portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      before { sign_in other_user }

      it "blocks update" do
        patch portfolio_path(portfolio), params: { portfolio: { quantity: 20 } }
        expect(response).to redirect_to(portfolios_path)
      end
    end
  end

  describe "DELETE /portfolios/:id" do
    context "own portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      before { sign_in user }

      it "deletes the portfolio" do
        expect {
          delete portfolio_path(portfolio)
        }.to change { user.portfolios.count }.by(-1)
        expect(response).to redirect_to(portfolios_path)
      end
    end

    context "another user's portfolio" do
      let!(:portfolio) { Portfolio.create!(user: user, stock: stock, quantity: 10) }

      before { sign_in other_user }

      it "blocks deletion" do
        delete portfolio_path(portfolio)
        expect(response).to redirect_to(portfolios_path)
      end
    end
  end
end