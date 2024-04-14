class CheckoutsController < ApplicationController
  def create
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    cart = params[:cart]
    line_items = cart.map do |item|
      product = Product.find(item["id"])
      product_stock = product.stocks.find{ |ps| ps.size == item["size"] }

      if product_stock.amount < item["quantity"].to_i
        render json: { error: "Not enough stock for #{product.name} in size #{item["size"]}. Only #{product_stock.amount} left." }, status: 400
        return
      end
        { 
        quantity: item["quantity"].to_i,
        price_data: { 
          product_data: {
            name: item["name"],
            metadata: { product_id: product.id, size: item["size"], product_stock_id: product_stock.id }
          },
          currency: "usd",
          unit_amount: item["price"].to_i
        }
      } 
    end
    
       puts "line_items: #{line_items}"

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
  def calculate_taxes(province, total_price)
    gst_rates = {
      'Alberta' => 0.05,
      'British Columbia' => 0.05,
      'Manitoba' => 0.05,
      'New Brunswick' => 0.15, # HST
      'Newfoundland and Labrador' => 0.15, # HST
      'Northwest Territories' => 0.05,
      'Nova Scotia' => 0.15, # HST
      'Nunavut' => 0.05,
      'Ontario' => 0.13, # HST
      'Prince Edward Island' => 0.15, # HST
      'Quebec' => 0.05,
      'Saskatchewan' => 0.06,
      'Yukon' => 0.05
    }
  
    pst_rates = {
      'British Columbia' => 0.07,
      'Manitoba' => 0.08,
      'Saskatchewan' => 0.06
    }
  
    gst_rate = gst_rates[province] || 0
    pst_rate = pst_rates[province] || 0
    total_taxes = total_price * (gst_rate + pst_rate)
  
    { gst: total_price * gst_rate, pst: total_price * pst_rate, total_taxes: total_taxes }
  end
  
  def success
    render :success
  end

  def cancel
    render :cancel
  end
  end