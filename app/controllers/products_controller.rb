class ProductsController < ApplicationController
    def show
      @product = Product.find(params[:id])
    end
    def index
      @pagy, @products = pagy(Product.all, items: 6)
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    @products = @products.search(params[:keyword]) if params[:keyword].present?
    @pagy, @products = pagy(@products)
    @products_pagy = @pagy  # Set @products_pagy to the pagy object 
    end
  end