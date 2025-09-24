# require 'rails_helper'

# RSpec.describe "User Registration", type: :request do
#   it "allows a new user to register" do
#     post user_registration_path, params: {
#       user: {
#         username: "traderjoe",
#         email: "trader@example.com",
#         password: "password123",
#         password_confirmation: "password123"
#       }
#     }

#     follow_redirect!

#     expect(response.body).to match(/sign up successfully|confirmation link/i)
#     expect(User.last.email).to eq("trader@example.com")
#   end
# end

require "rails_helper"

RSpec.describe "User Registration", type: :request do
  describe "POST /users" do
    it "allows a new user to register and sends confirmation email" do
      # Clear emails before test run
      ActionMailer::Base.deliveries.clear

      expect {
        post user_registration_path, params: {
          user: {
            username: "traderjoe",
            email: "trader@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.to change { User.count }.by(1)   # user record created
       .and change { ActionMailer::Base.deliveries.count }.by(1) # email sent

      follow_redirect!

      # Ensure page content hints about confirmation
      expect(response.body).to match(/confirmation link|email/i)

      # Ensure user is stored properly
      user = User.last
      expect(user.email).to eq("trader@example.com")
      expect(user.confirmed?).to be(false) # should not be confirmed yet
    end
  end
end
