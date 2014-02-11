require 'spec_helper'

describe SessionController do

  describe "GET 'first'" do
    it "returns http success" do
      get 'first'
      response.should be_success
    end
  end

  describe "GET 'second'" do
    it "returns http success" do
      get 'second'
      response.should be_success
    end
  end

  describe "GET 'login'" do
    it "returns http success" do
      get 'login'
      response.should be_success
    end
  end

  describe "GET 'logout'" do
    it "returns http success" do
      get 'logout'
      response.should be_success
    end
  end

end
