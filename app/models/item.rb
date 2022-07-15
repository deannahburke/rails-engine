class Item < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :unit_price

  belongs_to :merchant

  def self.search_all(query_params)
    where("name ILIKE ?", "%#{query_params}%")
  end
end
