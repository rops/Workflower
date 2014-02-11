require 'spec_helper'

describe CartController do

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'add_item'" do
    it "returns http success" do
      get 'add_item'
      response.should be_success
    end
  end

  describe "GET 'delete_item'" do
    it "returns http success" do
      get 'delete_item'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "returns http success" do
      get 'destroy'
      response.should be_success
    end
  end

end
