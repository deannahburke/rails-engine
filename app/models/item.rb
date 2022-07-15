class Item < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :unit_price

  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items, dependent: :destroy 

  def self.search_all(query_params)
    where("name ILIKE ?", "%#{query_params}%")
  end
end
