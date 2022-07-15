require 'rails_helper'

describe "Merchants API" do
  it "sends list of merchants" do
    create_list(:merchant, 5)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants).to have_key(:data)
    expect(Merchant.all.count).to eq(5)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it "can get one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to be_a(String)

    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to eq('merchant')


    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to have_key(:name)
  end

  it "can get all a merchants items" do
    merchant = create(:merchant)
    merchant2 = create(:merchant)
    items = create_list(:item, 10, merchant_id: merchant.id)
    items2 = create_list(:item, 7, merchant_id: merchant2.id)

    get "/api/v1/merchants/#{merchant.id}/items"

    results = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(results).to have_key(:data)

    expect(merchant.items.count).to eq(10)
    expect(merchant.items.count).to_not eq(17)
    expect(merchant.items.count).to_not eq(7)

    items = results[:data]

    items.each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:attributes)
      expect(item[:attributes][:name]).to be_a(String)
      expect(item[:attributes][:description]).to be_a(String)
      expect(item[:attributes][:unit_price]).to be_an(Float)
      expect(item[:attributes][:merchant_id]).to be_an(Integer)
    end
  end

  xit "will return 404 if merchant id is invalid" do
    get "/api/v1/merchants/999999999/items"

    expect(response).to have_http_status(404)
    expect{Merchant.find(merchant.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can return a single merchant which matches a search term" do
    merchant = create(:merchant, name: "Turing")
    merchant2 = create(:merchant, name: "Ring World")
    merchant3 = create(:merchant, name: "Tuna Stop")

    search = "Ring"
    
    get "/api/v1/merchants/find?name=#{search}"

    search_result = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(search_result).to have_key(:data)
    expect(search_result[:data][:attributes][:name]).to eq("Ring World")
  end

  it "will return an empty object if no match is found" do
    merchant = create(:merchant, name: "Turing")
    merchant2 = create(:merchant, name: "Ring World")
    merchant3 = create(:merchant, name: "Tuna Stop")

    search = "xylophone"

    get "/api/v1/merchants/find?name=#{search}"

    search_result = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
  end

  it "will return 400 if no search params specified" do
    merchant = create(:merchant, name: "Turing")
    merchant2 = create(:merchant, name: "Ring World")
    merchant3 = create(:merchant, name: "Tuna Stop")

    get "/api/v1/merchants/find?name="

    expect(response).to have_http_status(400)
  end
end
