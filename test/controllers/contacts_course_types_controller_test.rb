require 'test_helper'

class ContactsCourseTypesControllerTest < ActionController::TestCase
  setup do
    @contacts_course_type = contacts_course_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contacts_course_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contacts_course_type" do
    assert_difference('ContactsCourseType.count') do
      post :create, contacts_course_type: { contact_id: @contacts_course_type.contact_id, course_type_id: @contacts_course_type.course_type_id }
    end

    assert_redirected_to contacts_course_type_path(assigns(:contacts_course_type))
  end

  test "should show contacts_course_type" do
    get :show, id: @contacts_course_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contacts_course_type
    assert_response :success
  end

  test "should update contacts_course_type" do
    patch :update, id: @contacts_course_type, contacts_course_type: { contact_id: @contacts_course_type.contact_id, course_type_id: @contacts_course_type.course_type_id }
    assert_redirected_to contacts_course_type_path(assigns(:contacts_course_type))
  end

  test "should destroy contacts_course_type" do
    assert_difference('ContactsCourseType.count', -1) do
      delete :destroy, id: @contacts_course_type
    end

    assert_redirected_to contacts_course_types_path
  end
end
