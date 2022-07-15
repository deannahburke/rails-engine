class InvoiceItem < ApplicationRecord
  validates_presence_of :quantity
  validates_presence_of :unit_price

  belongs_to :invoice, dependent: :destroy
  belongs_to :item
end
