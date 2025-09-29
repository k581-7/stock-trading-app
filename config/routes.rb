Rails.application.routes.draw do
  get "testing/index"
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  root "dashboard#index"
  # root "stocks#test_quote"
  # root "stocks#index"
  
  # --- Trader routes ---
  # Portfolio (optionally with :stock_id param)
  # get "/portfolios",           to: "portfolios#index", as: :user_portfolio
  # get "/portfolios/:stock_id", to: "portfolios#show", as: :user_portfolio_by_stock
  resources :portfolios

  #dashboard
  get "dashboard", to: "dashboard#index"
  # Transactions
  get "/transactions", to: "transactions#index", as: :transactions

  # Trades (form + buy/sell actions)
  get  "/trades/new", to: "trades#new",  as: :new_trade
  post "/trades/buy", to: "trades#buy",  as: :buy_trade
  post "/trades/sell", to: "trades#sell", as: :sell_trade


  get "/trade_logs", to: "trade_logs#index", as: :trade_logs

  # Wallet routes
  get  "/wallet",        to: "wallets#show",   as: :wallet
post "/wallet/top_up", to: "wallets#top_up", as: :top_up_wallet
post "/wallet/withdraw", to: "wallets#withdraw", as: :withdraw_wallet
  # User routes
  resources :users, only: [] do
    member do
      patch :apply_broker
    end
  end

  # --- Admin routes ---
  namespace :admin do
    resources :users, only: [ :index, :show ] do
      member do
        patch :approve
        patch :revoke
        patch :approve_broker
        patch :reject_broker
      end
    end
  end

  # <%= link_to "Approve", approve_admin_user_path(user), method: :patch %>
  # <%= link_to "Revoke", revoke_admin_user_path(user), method: :patch %>

  get "test_quote", to: "stocks#test_quote"


  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path (Devise login page)
  # devise_scope :user do
  #   root to: "devise/sessions#new"
  # end
end
