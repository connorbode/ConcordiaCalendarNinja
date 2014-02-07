require 'test_helper'

class CalendarControllerTest < ActionController::TestCase
  test "should get ninja" do
    get :ninja
    assert_response :success
  end

end
