require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:foobar)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Invalid email
    post password_resets_path, params: {password_reset: {email: ''}}
    assert_not flash.empty?
    assert_template 'password_resets/new'
    post password_resets_path, params: {password_reset: {email: @user.email}}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    user = assigns(:user)
    # Wrong mail
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url
    #Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    # Wrong token Right user
    user.toggle!(:activated)
    get edit_password_reset_path('', email: user.email)
    assert_redirected_to root_url
    # Right email Right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email
    # Invalid password
    patch password_reset_path(user.reset_token), params: {email: user.email,
                                                          user:{password: 'foobar', password_confirmation: 'foobaz'}}
    assert_select 'div#error_explanation'
    # Blank password
    patch password_reset_path(user.reset_token), params: {email: user.email,
                                                          user:{password: '', password_confirmation:'foobar'}}
    # assert_select 'div#error_explanation'
    assert_not flash.empty?
    assert_template 'password_resets/edit'
    patch password_reset_path(user.reset_token), params: {email: user.email,
                                                          user:{password: 'foobar', password_confirmation: 'foobar'}}
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end
