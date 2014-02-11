#require File.expand_path("../../test_helper", __FILE__)
#require File.dirname(__FILE__) + '/../test_helper'
require 'test_helper'
require 'rails/performance_test_help'

class TestTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory],:output => 'tmp/performance', :formats => [:flat] }

  def testa
    get '/step1'
  end

  def testb
    get '/step5'
  end

  def testc
    get '/step7'
  end

  def testd
    get '/step4'
  end
end
