require 'test_helper'

class SalesTargetsControllerTest < ActionController::TestCase
  setup do
    @sales_target = sales_targets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales_targets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sales_target" do
    assert_difference('SalesTarget.count') do
      post :create, sales_target: { report_period_id: @sales_target.report_period_id, staff_id: @sales_target.staff_id, user_id: @sales_target.user_id }
    end

    assert_redirected_to sales_target_path(assigns(:sales_target))
  end

  test "should show sales_target" do
    get :show, id: @sales_target
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sales_target
    assert_response :success
  end

  test "should update sales_target" do
    patch :update, id: @sales_target, sales_target: { report_period_id: @sales_target.report_period_id, staff_id: @sales_target.staff_id, user_id: @sales_target.user_id }
    assert_redirected_to sales_target_path(assigns(:sales_target))
  end

  test "should destroy sales_target" do
    assert_difference('SalesTarget.count', -1) do
      delete :destroy, id: @sales_target
    end

    assert_redirected_to sales_targets_path
  end
end
