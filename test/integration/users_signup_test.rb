require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
  test "invalid signup information" do
    get signup_path
    # before_count = User.count
    assert_no_difference 'User.count' do
    post users_path, params:{
      user: {name: "", email: "foobar@invalid", password: "foo", password_confirmation: "foo"}
    }
    end
    # after_count = User.count
    # assert_equal before_count, after_count
    assert_template 'users/new'
  end

  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params:{
        user: {name: "Example User", email: "example@foobar.com", password: "password", password_confirmation: "password"}
      }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    log_in_as(user)
    assert_not is_logged_in?
    get edit_account_activation_path("Invalid token")
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
