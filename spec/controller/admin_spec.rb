require 'rails_helper'

RSpec.describe Admin::UsersController, type: :request do
  let!(:admin_user) do
    User.create!(
      username: "admin",
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      role: "admin",   # make sure your User model has this or similar
      approved: true
    )
  end

  let!(:trader) do
    User.create!(
      username: "traderjoe",
      email: "trader@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: Time.current,
      role: "trader",
      approved: false
    )
  end

  before do
    sign_in admin_user
  end

  describe "PATCH /admin/users/:id/approve" do
    it "approves a user as trader" do
      patch approve_admin_user_path(trader)

      expect(response).to redirect_to(admin_users_path)
      follow_redirect!

      expect(response.body).to include("#{trader.username} approved as trader.")
      expect(trader.reload.approved).to eq(true)
    end
  end

  describe "PATCH /admin/users/:id/revoke" do
    before { trader.update!(approved: true) }

    it "revokes a user's approval" do
      patch revoke_admin_user_path(trader)

      expect(response).to redirect_to(admin_users_path)
      follow_redirect!

      expect(response.body).to include("#{trader.username}'s approval revoked.")
      expect(trader.reload.approved).to eq(false)
    end
  end
end
