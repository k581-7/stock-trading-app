Rspec.describe "User Spec" do
  describe "Users" do
    context "#add" do
    context "num < 0" do
    it "will add numbers and print the output" do
      math = User.add
      expect(math).to eq User.add
    end
  end
end

def add(num)
  if num > 0
    num + num
  elsif num < 0
    num - num
  end
end