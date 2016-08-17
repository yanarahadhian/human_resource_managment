require 'test_helper'

class AddressesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  setup do
    @user = users(:hrm_test)
    sign_in :user, @user
  end

  context "when displaying index" do
    setup do
      get :index
    end
    should render_template :index
  end

  context "when create address" do
    setup do
      get:create
    end
    should respond_with :success
    should render_template :create
  end

  context "should update address" do
   setup do
        @params = {:address => "Jalan M.toha"}
      end
   should respond_with :success
   should render_template :edit
  end
end