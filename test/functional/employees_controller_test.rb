require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  context "when displaying index" do
    setup do
      get :index
    end
    should render_template :index
  end

  context "when create employee" do
    setup do
      get:create
    end
    should respond_with :success
    should render_template :create
  end

  context "should update employee" do
   setup do
        @params = {:address => "Jalan M.toha"}
      end
   should respond_with :success
   should render_template :edit
  end

  context "should delete employee" do
   setup do
        post:delete
      end
   should respond_with :success
   should render_template :index
  end
end
