require 'rails_helper'

RSpec.describe Stock, type: :model do
  subject { described_class.new(name: "Apple", symbol: "AAPL", current_price: 120.0) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:symbol) }
    it { should validate_uniqueness_of(:symbol) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without name' do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it 'is invalid with negative current_price' do
      subject.current_price = -10.0
      expect(subject).to_not be_valid
    end
  end
end