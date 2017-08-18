require 'test_helper'

class StickersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get stickers_index_url
    assert_response :success
  end

end
