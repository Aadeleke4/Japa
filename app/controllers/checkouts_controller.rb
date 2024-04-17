class CheckoutsController < ApplicationController
  def create
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    cart = params[:cart]
    province = params[:province]

    line_items = cart.map do |item|
      product = Product.find(item["id"])
      product_stock = product.stocks.find_by(size: item["size"])

      if product_stock.amount < item["quantity"].to_i
        render json: { errors: ["Not enough stock for #{product.name} in size #{item["size"]}. Only #{product_stock.amount} left."] }, status: 400
        return
      end

      total_price = item["price"].to_i 
      total_price_with_taxes = calculate_total_price_with_taxes(total_price, province)

      {
        quantity: item["quantity"].to_i,
        price_data: {
          product_data: {
            name: item["name"],
            metadata: { product_id: product.id, size: item["size"], product_stock_id: product_stock.id }
          },
          currency: "usd",
          unit_amount: total_price_with_taxes/100
        }
      }
    end

    session = Stripe::Checkout::Session.create(
      mode: "payment",
      line_items: line_items,
      success_url: "http://localhost:3000/success",
      cancel_url: "http://localhost:3000/cancel",
      shipping_address_collection: {
        allowed_countries: ['US', 'CA']
      }
    )

    render json: { url: session.url }
  end

  def calculate_total_price_with_taxes(total_price, province)
    tax_rates = {
      'Alberta' => { gst: 0.05, pst: 0 },
      'British Columbia' => { gst: 0.05, pst: 0.07 },
      'Manitoba' => { gst: 0.05, pst: 0.08 },
      # Add more provinces with their tax rates
    }

    taxes = tax_rates[province] || { gst: 0, pst: 0 }
  total_taxes = total_price * (taxes[:gst] + taxes[:pst])
  total_price_with_taxes = total_price + total_taxes

  (total_price_with_taxes * 100).to_i  # Convert to cents for Stripe
  end

  def success
    render :success
  end

  def cancel
    render :cancel
  end
end
