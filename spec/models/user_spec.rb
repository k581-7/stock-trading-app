require 'rails_helper'

RSpec.describe User, type: :model do
  describe "role enum" do
    it "defaults to trader" do
      u = User.create!(
        email: "a@b.com",
        password: "Passw0rd!",
        username: "testuser1"
      )
      expect(u.role).to eq("trader")
      expect(u.trader?).to be true
      expect(u.admin?).to be false
      expect(u.broker?).to be false
    end

    it "can change roles via bang methods" do
      u = User.create!(
        email: "rolechange@b.com",
        password: "Passw0rd!",
        username: "testuser_rolechange"
      )
      u.admin!
      expect(u.admin?).to be true
      expect(u.role).to eq("admin")
    end
  end

  describe "#approved?" do
    it "is false for traders" do
      u = User.create!(
        email: "d@b.com",
        password: "Passw0rd!",
        username: "testuser4"
      )
      expect(u.approved?).to be false
    end

    it "is true for brokers" do
      u = User.create!(
        email: "e@b.com",
        password: "Passw0rd!",
        username: "testuser5",
        role: :broker
      )
      expect(u.approved?).to be true
    end

    it "is true for admins" do
      u = User.create!(
        email: "f@b.com",
        password: "Passw0rd!",
        username: "testuser6",
        role: :admin
      )
      expect(u.approved?).to be true
    end
  end

  describe "approval_date handling" do
    it "is nil initially" do
      u = User.create!(
        email: "g@b.com",
        password: "Passw0rd!",
        username: "testuser7"
      )
      expect(u.approval_date).to be_nil
    end

    it "sets approval_date when promoted to broker" do
      u = User.create!(
        email: "h@b.com",
        password: "Passw0rd!",
        username: "testuser8"
      )
      u.update!(role: :broker)
      # expect(u.broker?).to be true
      u.reload
      expect(u.approval_date).to be_present
    end

    it "clears approval_date if demoted back to trader" do
      u = User.create!(
        email: "i@b.com",
        password: "Passw0rd!",
        username: "testuser9",
        role: :broker
      )
      u.update!(role: :trader)
      expect(u.trader?).to be true
      expect(u.approval_date).to be_nil
    end
  end
end
