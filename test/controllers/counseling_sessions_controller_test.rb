require 'test_helper'

class CounselingSessionsControllerTest < ActionController::TestCase
  setup do
    @counseling_session = counseling_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:counseling_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create counseling_session" do
    assert_difference('CounselingSession.count') do
      post :create, counseling_session: { actual_duration_in_minutes: @counseling_session.actual_duration_in_minutes, client_id: @counseling_session.client_id, counselor_id: @counseling_session.counselor_id, estimate_duration_in_minutes: @counseling_session.estimate_duration_in_minutes, payout_id: @counseling_session.payout_id, price_in_cents: @counseling_session.price_in_cents, refund_amount_in_cents: @counseling_session.refund_amount_in_cents, secure_id: @counseling_session.secure_id, slug: @counseling_session.slug, start_datetime: @counseling_session.start_datetime, stripe_charge_id: @counseling_session.stripe_charge_id }
    end

    assert_redirected_to counseling_session_path(assigns(:counseling_session))
  end

  test "should show counseling_session" do
    get :show, id: @counseling_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @counseling_session
    assert_response :success
  end

  test "should update counseling_session" do
    patch :update, id: @counseling_session, counseling_session: { actual_duration_in_minutes: @counseling_session.actual_duration_in_minutes, client_id: @counseling_session.client_id, counselor_id: @counseling_session.counselor_id, estimate_duration_in_minutes: @counseling_session.estimate_duration_in_minutes, payout_id: @counseling_session.payout_id, price_in_cents: @counseling_session.price_in_cents, refund_amount_in_cents: @counseling_session.refund_amount_in_cents, secure_id: @counseling_session.secure_id, slug: @counseling_session.slug, start_datetime: @counseling_session.start_datetime, stripe_charge_id: @counseling_session.stripe_charge_id }
    assert_redirected_to counseling_session_path(assigns(:counseling_session))
  end

  test "should destroy counseling_session" do
    assert_difference('CounselingSession.count', -1) do
      delete :destroy, id: @counseling_session
    end

    assert_redirected_to counseling_sessions_path
  end
end
