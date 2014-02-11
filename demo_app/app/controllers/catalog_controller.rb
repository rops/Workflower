class CatalogController < ApplicationController
  def show
  	@items = Item.all
  	@cart = current_cart.cart_items
  end
end
