Rails.application.routes.draw do
  get "testing/index"
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  # root "portfolio#index"
  root "stocks#test_quote"

  # --- Trader routes ---
  # Portfolio (optionally with :stock_id param)
  get "/portfolio",           to: "portfolio#show", as: :portfolio
  get "/portfolio/:stock_id", to: "portfolio#show", as: :show_portfolio

  # Transactions
  get "/transactions", to: "transactions#index", as: :transactions

  # Trades (form + buy/sell actions)
  get  "/trades/new", to: "trades#new",  as: :new_trade
  post "/trades/buy", to: "trades#buy",  as: :buy_trade
  post "/trades/sell", to: "trades#sell", as: :sell_trade

  # --- Admin routes ---
  namespace :admin do
    resources :users, only: [ :index, :show ] do
      member do
        patch :approve
        patch :revoke
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
