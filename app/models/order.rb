class Order < ApplicationRecord
    has_many :order_products,dependent: :destroy
    has_many :products, through: :order_products
    belongs_to :user, optional: true

    #belongs_to :address, optional: true
    validates :address, presence: true, length: { maximum: 255 }
end
