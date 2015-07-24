require 'test_helper'

class BookPricesControllerTest < ActionController::TestCase
  setup do
    @book_price = book_prices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:book_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create book_price" do
    assert_difference('BookPrice.count') do
      post :create, book_price: { book_id: @book_price.book_id, prices: @book_price.prices, user_id: @book_price.user_id }
    end

    assert_redirected_to book_price_path(assigns(:book_price))
  end

  test "should show book_price" do
    get :show, id: @book_price
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @book_price
    assert_response :success
  end

  test "should update book_price" do
    patch :update, id: @book_price, book_price: { book_id: @book_price.book_id, prices: @book_price.prices, user_id: @book_price.user_id }
    assert_redirected_to book_price_path(assigns(:book_price))
  end

  test "should destroy book_price" do
    assert_difference('BookPrice.count', -1) do
      delete :destroy, id: @book_price
    end

    assert_redirected_to book_prices_path
  end
end
