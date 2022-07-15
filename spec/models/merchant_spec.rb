require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
  end

  describe 'relationships' do
    it { should have_many :items }
  end

  describe 'class methods' do
    it 'can return a single merchant from search in alphabetical order' do
      merchant = create(:merchant, name: "Turing")
      merchant2 = create(:merchant, name: "Ring World")
      merchant3 = create(:merchant, name: "Tuna Stop")

      expect(Merchant.search("Ring")).to eq(merchant2)
      expect(Merchant.search("Ring")).to_not eq(merchant)
    end
  end
end
