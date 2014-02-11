class CartItem < ActiveRecord::Base
  attr_accessible :cart_id, :item_id
  belongs_to :cart
  belongs_to :item
end
