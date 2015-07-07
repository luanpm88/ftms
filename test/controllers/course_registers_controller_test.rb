require 'test_helper'

class CourseRegistersControllerTest < ActionController::TestCase
  setup do
    @course_register = course_registers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:course_registers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create course_register" do
    assert_difference('CourseRegister.count') do
      post :create, course_register: { created_date: @course_register.created_date, user_id: @course_register.user_id }
    end

    assert_redirected_to course_register_path(assigns(:course_register))
  end

  test "should show course_register" do
    get :show, id: @course_register
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @course_register
    assert_response :success
  end

  test "should update course_register" do
    patch :update, id: @course_register, course_register: { created_date: @course_register.created_date, user_id: @course_register.user_id }
    assert_redirected_to course_register_path(assigns(:course_register))
  end

  test "should destroy course_register" do
    assert_difference('CourseRegister.count', -1) do
      delete :destroy, id: @course_register
    end

    assert_redirected_to course_registers_path
  end
end
