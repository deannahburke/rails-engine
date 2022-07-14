class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
  item = Item.create(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: 201
    else
      render status: 404
    end
  end

  def update
  item = Item.find(params[:id])
    if item.update(item_params)
      render json: ItemSerializer.new(item), status: 200
    else
      render status: 404
    end
  end

  def destroy
    Item.find(params[:id]).destroy
  end

  private
    def item_params
      params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
    end
end
