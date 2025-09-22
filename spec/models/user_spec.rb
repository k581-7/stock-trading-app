require 'rails_helper'

RSpec.describe User, type: :model do
  it "defaults to trader" do
    u = User.create!(
      email: "a@b.com",
      password: "Passw0rd!",
      username: "testuser1"
    )
    expect(u.role).to eq("trader")
    expect(u.trader?).to be true
  end

  it "sets approval_date when promoted to broker" do
    u = User.create!(
      email: "b@b.com",
      password: "Passw0rd!",
      username: "testuser2"
    )
    u.update!(role: :broker)
    expect(u.broker?).to be true
    expect(u.approval_date).to be_present
  end

  it "clears approval_date if demoted back to trader" do
    u = User.create!(
      email: "c@b.com",
      password: "Passw0rd!",
      role: :broker,
      username: "testuser3"
    )
    u.update!(role: :trader)
    expect(u.trader?).to be true
    expect(u.approval_date).to be_nil
  end
end
