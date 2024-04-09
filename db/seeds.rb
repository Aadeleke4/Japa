# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

require 'faker'

# Create categories
categories = ['Sweat Shirt', 'Belt', 'Accesories', 'Hats']

categories.each do |category_name|
  Category.create(name: category_name)
end

# Create products
100.times do
  name = Faker::Commerce.product_name
  description = Faker::Lorem.sentence
  price = Faker::Commerce.price(range: 50..500.0)
  category_id = rand(1..4)

  Product.create(
    name: name,
    description: description,
    price: price,
    category_id: category_id
  )
end
