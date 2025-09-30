Rails.application.routes.draw do
  get "testing/index"
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  root "dashboard#index"

  # --- Trader routes ---
  # Portfolio (optionally with :stock_id param)
  resources :portfolios

  # dashboard
  get "dashboard", to: "dashboard#index"

  # Transactions
  get "/transactions", to: "transactions#index", as: :transactions

  # Trades (form + buy/sell actions)
  get  "/trades/new", to: "trades#new",  as: :new_trade
  post "/trades/buy", to: "trades#buy",  as: :buy_trade
  post "/trades/sell", to: "trades#sell", as: :sell_trade


  get "/trade_logs", to: "trade_logs#index", as: :trade_logs

  # Wallet routes
  get "/wallet",        to: "wallets#show",   as: :wallet
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
    resources :users do
      member do
        patch :approve
        patch :revoke
        patch :approve_broker
        patch :reject_broker
        delete :delete
      end
    end
  end

  get "test_quote", to: "stocks#test_quote"
  post "stocks/update_prices", to: "stocks#update_prices", as: :update_prices


  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
