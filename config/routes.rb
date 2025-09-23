Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # --- Trader routes ---
  # Portfolio (optionally with :stock_id param)
  get "/portfolio",          to: "portfolios#show", as: :portfolio
  get "/portfolio/:stock_id", to: "portfolios#show", as: :show_portfolio

  # Transactions
  get "/transactions",       to: "transactions#index", as: :transactions

  # Trades (form + buy/sell actions)
  get  "/trades/new",        to: "trades#new",  as: :new_trade
  post "/trades/buy",        to: "trades#buy",  as: :buy_trade
  post "/trades/sell",       to: "trades#sell", as: :sell_trade

  # --- Admin routes ---
  namespace :admin do
    resources :users do
      member do
        patch :approve
        patch :revoke
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "users#show"
end
