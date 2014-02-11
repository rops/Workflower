require 'spec_helper'

describe CheckoutController do

  describe "GET 'shipment'" do
    it "returns http success" do
      get 'shipment'
      response.should be_success
    end
  end

  describe "GET 'payment'" do
    it "returns http success" do
      get 'payment'
      response.should be_success
    end
  end

  describe "GET 'submit'" do
    it "returns http success" do
      get 'submit'
      response.should be_success
    end
  end

end
