require 'rails_helper'

RSpec.describe Item do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :unit_price }
  end

  describe 'relationships' do
    it { should belong_to :merchant}
    it { should have_many :invoice_items}
    it { should have_many(:invoices).through(:invoice_items)}
  end

  describe 'class methods' do
    it "can return all items from search query in alphabetical order" do
      merchant = create(:merchant)
      merchant2 = create(:merchant)
      item1 = create(:item, name: "necklace", merchant_id: merchant.id)
      item2 = create(:item, name: "brace", merchant_id: merchant.id)
      item3 = create(:item, name: "Neck Brace", merchant_id: merchant2.id)
      item4 = create(:item, name: "xylophone", merchant_id: merchant2.id)

      expect(Item.search_all("Ace")).to eq([item1, item2, item3])
      expect(Item.search_all("Ace")).to_not eq([item4])
      expect(Item.search_all("Ace")).to_not eq([])
    end
  end
end
