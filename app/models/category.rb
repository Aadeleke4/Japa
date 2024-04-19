class Category < ApplicationRecord
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
  end
  validates :name, uniqueness: { case_sensitive: false }, presence: true
  has_many :products
  
end