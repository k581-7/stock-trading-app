require 'rails_helper'

RSpec.describe "User Authentication", type: :request do
  let!(:user) do
    User.create!(
      username: "traderjoe",
      email: "trader@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.now
    )
  end

  it "allows a user to log in" do
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }

    follow_redirect!
    expect(response.body).to include("Signed in successfully") # adjust to your flash/message
  end

  it "allows a user to log out" do
    # First, log in
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      }
    }

    delete destroy_user_session_path
    follow_redirect!
    expect(response.body).to include("Signed out successfully") # adjust to your flash/message
  end
end
