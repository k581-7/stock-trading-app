require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  it "requires the presence of a title" do
    expect(Stock.new).not_to be_valid
  end
end
