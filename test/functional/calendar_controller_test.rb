require 'test_helper'

class CalendarControllerTest < ActionController::TestCase

  test "should return error if session is missing" do
    post :ninja
    assert_response(400)

    expected = {
      'description' => "session parameter missing"
    }

    actual = JSON.parse(response.body)
    assert_equal expected['description'], actual['description']
  end

  test "should return error if session is not an integer in range [1..4]" do
    testVals = [
      "Winter",
      "2301x",
      "212.2",
      "&&SASZ",
      "joiaw239",
      "21LL",
      "0",
      "5"
    ]

    expected = {
      'description' => "invalid session parameter"
    }

    testVals.each { |testVal|
      post :ninja, session: testVal
      assert_response(400)
      actual = JSON.parse(response.body)
      assert_equal expected['description'], actual['description']
    }
  end

  test "should return error if myconcordia_username is missing" do
    post :ninja, session: 4
    assert_response(400)

    expected = {
      'description' => "myconcordia_username parameter missing"
    }

    actual = JSON.parse(response.body)
    assert_equal expected['description'], actual['description']
  end

  test "should return error if myconcordia_password parameter missing" do
    post :ninja, session: 4, myconcordia_username: "fake"
    assert_response(400)

    expected = {
      'description' => "myconcordia_password parameter missing"
    }

    actual = JSON.parse(response.body)
    assert_equal expected['description'], actual['description']
  end

  test "should return error if mechanize times out while contacting MyConcordia" do
    Schedule.timeout = 0.001
    post :ninja, session: 4, myconcordia_username: "fake", myconcordia_password: "fake"
    assert_response(400)

    expected = {
      'description' => "failed to contact MyConcordia"
    }

    actual = JSON.parse(response.body)
    assert_equal expected['description'], actual['description']
  end

  test "should return error if MyConcordia credentials are invalid" do
    post :ninja, session: 4, myconcordia_username: "fake", myconcordia_password: "fake"
    assert_response(400)

    expected = {
      'description' => "invalid MyConcordia credentials"
    }

    actual = JSON.parse(response.body)
    assert_equal expected['description'], actual['description']
  end

  test "returns an array of timeslots if supplied with a valid Concordia timetable" do
    file = File.open(Rails.root + "test/fixtures/sample_timetable.html", "rb")
    contents = file.read

    Schedule.any_instance.stubs(:fetch)
    Schedule.any_instance.stubs(:html).returns(contents)

    post :ninja, session: 4, myconcordia_username: "fake", myconcordia_password: "fake"
    actual = JSON.parse(response.body)

    assert_response :ok
    assert_equal 7, actual.length
  end
end
