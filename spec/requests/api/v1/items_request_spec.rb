require 'rails_helper'

describe "Items API" do
  it "sends list of all items" do

    merchant = create(:merchant)
    create_list(:item, 10, merchant_id: merchant.id)

    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items).to have_key(:data)
    expect(Item.all.count).to eq(10)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)
    end
  end

  it "can get one item" do
    merchant = create(:merchant)
    item_id = create(:item, merchant_id: merchant.id).id

    get "/api/v1/items/#{item_id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to be_a(String)

    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to eq('item')

    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes]).to have_key(:merchant_id)
  end

  it "can create a new item" do
    merchant = create(:merchant)
    item_params = ({
                    name: "Rubber Duck",
                    description: "Yellow, plastic, excellent desk company",
                    unit_price: 4.05,
                    merchant_id: (merchant.id)
      })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    new_item = Item.last

    expect(response).to be_successful
    expect(new_item.name).to eq(item_params[:name])
    expect(new_item.name).to eq("Rubber Duck")
    expect(new_item.description).to eq("Yellow, plastic, excellent desk company")
    expect(new_item.unit_price).to eq(4.05)
    expect(new_item.merchant_id).to eq(merchant.id)
  end

  it "will not create item without all params" do
    merchant = create(:merchant)
    item_params = ({
                    name: nil,
                    description: "Yellow, plastic, excellent desk company",
                    unit_price: 4.05,
                    merchant_id: nil
                  })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    expect(response).to have_http_status(404)
  end

  it "can update existing item record" do
    merchant_id = create(:merchant).id
    item_id = create(:item, merchant_id: merchant_id).id
    previous_price = Item.last.unit_price
    updated_params = { unit_price: 5.99 }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{item_id}", headers: headers, params: JSON.generate({item: updated_params})

    item = Item.find_by(id: item_id)

    expect(response).to be_successful
    expect(item.unit_price).to_not eq(previous_price)
    expect(item.unit_price).to eq(5.99)
  end

  it "will not update item without all params" do
    merchant_id = create(:merchant).id
    item_id = create(:item, merchant_id: merchant_id).id
    previous_price = Item.last.unit_price
    updated_params = { unit_price: nil }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{item_id}", headers: headers, params: JSON.generate({item: updated_params})

    item = Item.find_by(id: item_id)
    expect(response).to have_http_status(404)
  end

  it "can destroy an item" do
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)

    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "destroys invoice if item is destroyed" do
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)
    invoice = Invoice.create(status: "In progress", merchant_id: merchant.id)
    invoice_item = InvoiceItem.create(quantity: 2, unit_price: 5.99, invoice_id: invoice.id, item_id: item.id)

    expect(Invoice.all).to eq([invoice])

    item.destroy

    expect(Invoice.all).to eq([])
  end
  
  it "sends merchant associated with the item" do
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)

    get "/api/v1/items/#{item.id}/merchant"

    result = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(result).to be_a(Hash)
    expect(result).to have_key(:data)
    expect(result[:data]).to have_key(:type)
    expect(result[:data][:type]).to eq("merchant")
  end

  it "can return all items that match a search term" do
    merchant = create(:merchant)
    merchant2 = create(:merchant)
    item = create(:item, name: "necklace", merchant_id: merchant.id)
    item2 = create(:item, name: "brace", merchant_id: merchant.id)
    item3 = create(:item, name: "Neck Brace", merchant_id: merchant2.id)
    item4 = create(:item, name: "xylophone", merchant_id: merchant2.id)

    search = "Ace"

    get "/api/v1/items/find_all?name=#{search}"

    search_result = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful
    expect(search_result).to have_key(:data)
    expect(search_result[:data]).to be_an(Array)
  end

  it "will return an empty object if no match is found" do
    merchant = create(:merchant)
    merchant2 = create(:merchant)
    item = create(:item, name: "necklace", merchant_id: merchant.id)
    item2 = create(:item, name: "brace", merchant_id: merchant.id)
    item3 = create(:item, name: "Neck Brace", merchant_id: merchant2.id)
    item4 = create(:item, name: "xylophone", merchant_id: merchant2.id)

    search = "peanut"

    get "/api/v1/items/find_all?name=#{search}"

    search_result = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
  end

  it "returns 400 if no search params specified" do
    merchant = create(:merchant)
    merchant2 = create(:merchant)
    item = create(:item, name: "necklace", merchant_id: merchant.id)
    item2 = create(:item, name: "brace", merchant_id: merchant.id)
    item3 = create(:item, name: "Neck Brace", merchant_id: merchant2.id)
    item4 = create(:item, name: "xylophone", merchant_id: merchant2.id)

    get "/api/v1/items/find_all?name="

    expect(response).to have_http_status(400)
  end
end
