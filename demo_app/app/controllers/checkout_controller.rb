class CheckoutController < ApplicationController
  

  def valid_payment(payment)
    payment.to_s != ''
  end

  def valid_ship(ship)
    ship.to_s != ''
  end

  def payment

  end

  def shipment
  	session[:card_number] = params[:card_number]
  end

  def submit
  	ship = params[:shipping_info]
  	cart = Cart.find_by_id(session[:cart_id])
  	if cart
  		cart.destroy
  		session.delete(:cart_id)
  	end
  	flash[:msg] = "Order Placed"
  	redirect_to '/'
  end
end
