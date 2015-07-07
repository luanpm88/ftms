require 'test_helper'

class ContactsCoursesControllerTest < ActionController::TestCase
  setup do
    @contacts_course = contacts_courses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contacts_courses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contacts_course" do
    assert_difference('ContactsCourse.count') do
      post :create, contacts_course: { contact_id: @contacts_course.contact_id, course_id: @contacts_course.course_id, course_register_id: @contacts_course.course_register_id }
    end

    assert_redirected_to contacts_course_path(assigns(:contacts_course))
  end

  test "should show contacts_course" do
    get :show, id: @contacts_course
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contacts_course
    assert_response :success
  end

  test "should update contacts_course" do
    patch :update, id: @contacts_course, contacts_course: { contact_id: @contacts_course.contact_id, course_id: @contacts_course.course_id, course_register_id: @contacts_course.course_register_id }
    assert_redirected_to contacts_course_path(assigns(:contacts_course))
  end

  test "should destroy contacts_course" do
    assert_difference('ContactsCourse.count', -1) do
      delete :destroy, id: @contacts_course
    end

    assert_redirected_to contacts_courses_path
  end
end
