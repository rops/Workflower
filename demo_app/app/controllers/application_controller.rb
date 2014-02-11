class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :current_user
  def current_user
  	if session[:user_id]
  		@user = User.find(session[:user_id])
  	end
  end

  def current_cart 
  	Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create 
    session[:cart_id] = cart.id
	cart
  end
end
