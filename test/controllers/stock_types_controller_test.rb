require 'test_helper'

class StockTypesControllerTest < ActionController::TestCase
  setup do
    @stock_type = stock_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stock_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stock_type" do
    assert_difference('StockType.count') do
      post :create, stock_type: { annoucing_user_ids: @stock_type.annoucing_user_ids, description: @stock_type.description, name: @stock_type.name, parent_id: @stock_type.parent_id, status: @stock_type.status, user_id: @stock_type.user_id }
    end

    assert_redirected_to stock_type_path(assigns(:stock_type))
  end

  test "should show stock_type" do
    get :show, id: @stock_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stock_type
    assert_response :success
  end

  test "should update stock_type" do
    patch :update, id: @stock_type, stock_type: { annoucing_user_ids: @stock_type.annoucing_user_ids, description: @stock_type.description, name: @stock_type.name, parent_id: @stock_type.parent_id, status: @stock_type.status, user_id: @stock_type.user_id }
    assert_redirected_to stock_type_path(assigns(:stock_type))
  end

  test "should destroy stock_type" do
    assert_difference('StockType.count', -1) do
      delete :destroy, id: @stock_type
    end

    assert_redirected_to stock_types_path
  end
end
