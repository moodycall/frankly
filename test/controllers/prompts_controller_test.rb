require 'test_helper'

class PromptsControllerTest < ActionController::TestCase
  setup do
    @prompt = prompts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:prompts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create prompt" do
    assert_difference('Prompt.count') do
      post :create, prompt: { audience_type: @prompt.audience_type, duration: @prompt.duration, email_message: @prompt.email_message, enable_email: @prompt.enable_email, enable_sms: @prompt.enable_sms, interval: @prompt.interval, is_active: @prompt.is_active, send_before_session: @prompt.send_before_session, sms_message: @prompt.sms_message }
    end

    assert_redirected_to prompt_path(assigns(:prompt))
  end

  test "should show prompt" do
    get :show, id: @prompt
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @prompt
    assert_response :success
  end

  test "should update prompt" do
    patch :update, id: @prompt, prompt: { audience_type: @prompt.audience_type, duration: @prompt.duration, email_message: @prompt.email_message, enable_email: @prompt.enable_email, enable_sms: @prompt.enable_sms, interval: @prompt.interval, is_active: @prompt.is_active, send_before_session: @prompt.send_before_session, sms_message: @prompt.sms_message }
    assert_redirected_to prompt_path(assigns(:prompt))
  end

  test "should destroy prompt" do
    assert_difference('Prompt.count', -1) do
      delete :destroy, id: @prompt
    end

    assert_redirected_to prompts_path
  end
end
