class TraderMailer < ApplicationMailer
  default from: "no-reply@stockapp.com"

  # Email for signup confirmation (Devise already does this, but you can customize)
  def confirmation_email(trader)
    @trader = trader
    mail(to: @trader.email, subject: "Confirm your Stock Trading account")
  end

  # Email for admin approval (when trader gets promoted to broker)
  def approval_email(trader)
    @trader = trader
    mail(to: @trader.email, subject: "Your Stock Trading account has been approved!")
  end
end

# spec/mailers/trader_mailer_spec.rb
require "rails_helper"

RSpec.describe TraderMailer, type: :mailer do
  let(:trader) do
    User.create!(
      username: "traderjoe",
      email: "trader@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,  # skip confirmable check
      role: :trader  # Use valid role from enum
    )
  end

  describe "#approval_email" do
    let(:mail) { TraderMailer.approval_email(trader) }

    it "renders the subject" do
      expect(mail.subject).to eq("Your Stock Trading account has been approved!")
    end

    it "sends to the correct email" do
      expect(mail.to).to eq([trader.email])
    end

    it "renders the body with username" do
      expect(mail.body.encoded).to match("Hello #{trader.username}")
    end
  end
end