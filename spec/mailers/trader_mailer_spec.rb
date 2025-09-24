require "rails_helper"

RSpec.describe TraderMailer, type: :mailer do
  let(:trader) do
    User.create!(
      username: "traderjoe",
      email: "trader@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      role: :trader
    )
  end

  describe "#approval_email" do
    let(:mail) { TraderMailer.approval_email(trader) }  # Changed from trader_mailer to approval_email

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
