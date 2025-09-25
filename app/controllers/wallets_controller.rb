class WalletsController < ApplicationController
  before_action :authenticate_user!
  skip_forgery_protection if Rails.env.test?  # avoids 422 in test

  def show
    current_user.ensure_wallet!
    @wallet = current_user.wallet
  end

  def top_up
    amount = params[:amount].to_d
    if amount > 0
      current_user.ensure_wallet!

      # increase balance
      current_user.wallet.update!(balance: current_user.wallet.balance + amount)

      # write trade log (quantity defaults to 0 for deposits)
      TradeLog.create!(transaction_type: "deposit", amount: amount)

      redirect_to wallet_path, notice: "Added #{helpers.number_to_currency(amount)} to wallet."
    else
      redirect_to wallet_path, alert: "Enter a valid amount."
    end
  end
end
