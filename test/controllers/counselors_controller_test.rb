require 'test_helper'

class CounselorsControllerTest < ActionController::TestCase
  setup do
    @counselor = counselors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:counselors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create counselor" do
    assert_difference('Counselor.count') do
      post :create, counselor: { advanced_scheduling_in_weeks: @counselor.advanced_scheduling_in_weeks, available_friday: @counselor.available_friday, available_monday: @counselor.available_monday, available_saturday: @counselor.available_saturday, available_sunday: @counselor.available_sunday, available_thursday: @counselor.available_thursday, available_tuesday: @counselor.available_tuesday, available_wednesday: @counselor.available_wednesday, bio: @counselor.bio, hourly_fee_in_cents: @counselor.hourly_fee_in_cents, hourly_rate_in_cents: @counselor.hourly_rate_in_cents, photo: @counselor.photo, profession_start_date: @counselor.profession_start_date, send_session_email_alerts: @counselor.send_session_email_alerts, send_session_sms_alerts: @counselor.send_session_sms_alerts, slug: @counselor.slug, user_id: @counselor.user_id }
    end

    assert_redirected_to counselor_path(assigns(:counselor))
  end

  test "should show counselor" do
    get :show, id: @counselor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @counselor
    assert_response :success
  end

  test "should update counselor" do
    patch :update, id: @counselor, counselor: { advanced_scheduling_in_weeks: @counselor.advanced_scheduling_in_weeks, available_friday: @counselor.available_friday, available_monday: @counselor.available_monday, available_saturday: @counselor.available_saturday, available_sunday: @counselor.available_sunday, available_thursday: @counselor.available_thursday, available_tuesday: @counselor.available_tuesday, available_wednesday: @counselor.available_wednesday, bio: @counselor.bio, hourly_fee_in_cents: @counselor.hourly_fee_in_cents, hourly_rate_in_cents: @counselor.hourly_rate_in_cents, photo: @counselor.photo, profession_start_date: @counselor.profession_start_date, send_session_email_alerts: @counselor.send_session_email_alerts, send_session_sms_alerts: @counselor.send_session_sms_alerts, slug: @counselor.slug, user_id: @counselor.user_id }
    assert_redirected_to counselor_path(assigns(:counselor))
  end

  test "should destroy counselor" do
    assert_difference('Counselor.count', -1) do
      delete :destroy, id: @counselor
    end

    assert_redirected_to counselors_path
  end
end
