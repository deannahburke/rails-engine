class Api::V1::SearchController < ApplicationController
  def merchant_search
    query_params = (params[:name])
    if query_params.blank?
      render status: 400
    else
      merchant = Merchant.search(query_params)
      if merchant.nil?
        render json: {data: {}}
      else
        render json: MerchantSerializer.new(merchant)
      end
    end
  end

  def items_search
    query_params = (params[:name])
      if query_params.blank?
        render status: 400
      else
        items = Item.search_all(query_params)
      if items.nil?
        render json: {data: {}}
      else
        render json: ItemSerializer.new(items)
      end
    end
  end
end
