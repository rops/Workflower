class User < ActiveRecord::Base
  attr_accessible :password, :username
  validates :username, presence:true
  validates :password, presence:true, :length => { :minimum => 6 }
end
