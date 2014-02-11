class CartController < ApplicationController
  
  def add_item
  	item = Item.find_by_id(params[:id])
  	if item 
	  	@cart = current_cart
	  	cart_item = @cart.cart_items.build(item_id:item.id)  	
	  	cart_item.save
	end
	redirect_to '/'
  	
  end

  def destroy
  	cart = Cart.find_by_id(session[:cart_id])
  	if cart
  		cart.destroy
  		session.delete(:cart_id)
  	end
  	redirect_to '/'
  end
end
