require 'test_helper'

class StockUpdatesControllerTest < ActionController::TestCase
  setup do
    @stock_update = stock_updates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stock_updates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stock_update" do
    assert_difference('StockUpdate.count') do
      post :create, stock_update: { book_id: @stock_update.book_id, created_date: @stock_update.created_date, quantity: @stock_update.quantity, type: @stock_update.type, user_id: @stock_update.user_id }
    end

    assert_redirected_to stock_update_path(assigns(:stock_update))
  end

  test "should show stock_update" do
    get :show, id: @stock_update
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stock_update
    assert_response :success
  end

  test "should update stock_update" do
    patch :update, id: @stock_update, stock_update: { book_id: @stock_update.book_id, created_date: @stock_update.created_date, quantity: @stock_update.quantity, type: @stock_update.type, user_id: @stock_update.user_id }
    assert_redirected_to stock_update_path(assigns(:stock_update))
  end

  test "should destroy stock_update" do
    assert_difference('StockUpdate.count', -1) do
      delete :destroy, id: @stock_update
    end

    assert_redirected_to stock_updates_path
  end
end
