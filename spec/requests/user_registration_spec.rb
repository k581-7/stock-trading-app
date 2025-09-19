require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  it "allows a new user to register" do
    post user_registration_path, params: {
      user: {
        username: "traderjoe",
        email: "trader@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    follow_redirect!

    expect(response.body).to include("Welcome") 
    expect(User.last.email).to eq("trader@example.com")
  end
end