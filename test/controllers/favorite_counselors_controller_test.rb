require 'test_helper'

class FavoriteCounselorsControllerTest < ActionController::TestCase
  setup do
    @favorite_counselor = favorite_counselors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:favorite_counselors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create favorite_counselor" do
    assert_difference('FavoriteCounselor.count') do
      post :create, favorite_counselor: { counselor_id: @favorite_counselor.counselor_id, user_id: @favorite_counselor.user_id }
    end

    assert_redirected_to favorite_counselor_path(assigns(:favorite_counselor))
  end

  test "should show favorite_counselor" do
    get :show, id: @favorite_counselor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @favorite_counselor
    assert_response :success
  end

  test "should update favorite_counselor" do
    patch :update, id: @favorite_counselor, favorite_counselor: { counselor_id: @favorite_counselor.counselor_id, user_id: @favorite_counselor.user_id }
    assert_redirected_to favorite_counselor_path(assigns(:favorite_counselor))
  end

  test "should destroy favorite_counselor" do
    assert_difference('FavoriteCounselor.count', -1) do
      delete :destroy, id: @favorite_counselor
    end

    assert_redirected_to favorite_counselors_path
  end
end
