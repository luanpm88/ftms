require 'test_helper'

class CourseTypesDiscountProgramsControllerTest < ActionController::TestCase
  setup do
    @course_types_discount_program = course_types_discount_programs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:course_types_discount_programs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create course_types_discount_program" do
    assert_difference('CourseTypesDiscountProgram.count') do
      post :create, course_types_discount_program: { course_type_id: @course_types_discount_program.course_type_id, discount_program_id: @course_types_discount_program.discount_program_id }
    end

    assert_redirected_to course_types_discount_program_path(assigns(:course_types_discount_program))
  end

  test "should show course_types_discount_program" do
    get :show, id: @course_types_discount_program
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @course_types_discount_program
    assert_response :success
  end

  test "should update course_types_discount_program" do
    patch :update, id: @course_types_discount_program, course_types_discount_program: { course_type_id: @course_types_discount_program.course_type_id, discount_program_id: @course_types_discount_program.discount_program_id }
    assert_redirected_to course_types_discount_program_path(assigns(:course_types_discount_program))
  end

  test "should destroy course_types_discount_program" do
    assert_difference('CourseTypesDiscountProgram.count', -1) do
      delete :destroy, id: @course_types_discount_program
    end

    assert_redirected_to course_types_discount_programs_path
  end
end
