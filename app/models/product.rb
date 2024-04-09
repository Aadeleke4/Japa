class Product < ApplicationRecord
    has_many_attached :images do |attachable|
        attachable.variant :thumb, resize_to_limit: [50, 50]
        attachable.variant :medium, resize_to_limit: [250, 250]
end
scope :search, -> (keyword) {
    where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", "%#{keyword.downcase}%", "%#{keyword.downcase}%")
  }
    belongs_to :category
    has_many :stocks
    has_many :order_products
    end