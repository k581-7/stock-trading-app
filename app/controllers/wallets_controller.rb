class WalletsController < ApplicationController
  before_action :authenticate_user!
  skip_forgery_protection if Rails.env.test?  # avoids 422 in test

def show
  @wallet = current_user.wallet

  # Make sure @wallet exists before querying
  if @wallet
    @wallet_logs = TradeLog.where(wallet: @wallet).order(created_at: :desc)
  else
    @wallet_logs = []
  end
end


  def top_up
    amount = params[:amount].to_d
    if amount > 0
      current_user.ensure_wallet!
      current_user.wallet.update!(balance: current_user.wallet.balance + amount)

      TradeLog.create!(
        user: current_user,
        wallet: current_user.wallet,
        transaction_type: "deposit",
        amount: amount,
        quantity: 0
      )

      redirect_to wallet_path, notice: "Added #{helpers.number_to_currency(amount)} to wallet."
    else
      redirect_to wallet_path, alert: "Enter a valid amount."
    end
  end

  def withdraw
    amount = params[:amount].to_d
    current_user.ensure_wallet!
    wallet = current_user.wallet

    if amount > 0 && wallet.balance >= amount
      wallet.update!(balance: wallet.balance - amount)

      TradeLog.create!(
        user: current_user,
        wallet: wallet,
        transaction_type: "withdraw",
        amount: amount,
        quantity: 0
      )

      redirect_to wallet_path, notice: "Withdrew #{helpers.number_to_currency(amount)} from wallet."
    else
      redirect_to wallet_path, alert: "Invalid amount or insufficient balance."
    end
  end
end