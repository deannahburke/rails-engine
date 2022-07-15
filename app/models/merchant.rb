class Merchant < ApplicationRecord
  validates_presence_of :name

  has_many :items

  def self.search(query_params)
    where("name ILIKE ?", "%#{query_params}%")
    .order(:name)
    .first
  end
end
