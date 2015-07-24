require 'test_helper'

class CoursePricesControllerTest < ActionController::TestCase
  setup do
    @course_price = course_prices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:course_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create course_price" do
    assert_difference('CoursePrice.count') do
      post :create, course_price: { course_id: @course_price.course_id, prices: @course_price.prices, user_id: @course_price.user_id }
    end

    assert_redirected_to course_price_path(assigns(:course_price))
  end

  test "should show course_price" do
    get :show, id: @course_price
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @course_price
    assert_response :success
  end

  test "should update course_price" do
    patch :update, id: @course_price, course_price: { course_id: @course_price.course_id, prices: @course_price.prices, user_id: @course_price.user_id }
    assert_redirected_to course_price_path(assigns(:course_price))
  end

  test "should destroy course_price" do
    assert_difference('CoursePrice.count', -1) do
      delete :destroy, id: @course_price
    end

    assert_redirected_to course_prices_path
  end
end
