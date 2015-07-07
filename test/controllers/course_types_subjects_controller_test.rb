require 'test_helper'

class CourseTypesSubjectsControllerTest < ActionController::TestCase
  setup do
    @course_types_subject = course_types_subjects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:course_types_subjects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create course_types_subject" do
    assert_difference('CourseTypesSubject.count') do
      post :create, course_types_subject: { course_type_id: @course_types_subject.course_type_id, subject_id: @course_types_subject.subject_id }
    end

    assert_redirected_to course_types_subject_path(assigns(:course_types_subject))
  end

  test "should show course_types_subject" do
    get :show, id: @course_types_subject
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @course_types_subject
    assert_response :success
  end

  test "should update course_types_subject" do
    patch :update, id: @course_types_subject, course_types_subject: { course_type_id: @course_types_subject.course_type_id, subject_id: @course_types_subject.subject_id }
    assert_redirected_to course_types_subject_path(assigns(:course_types_subject))
  end

  test "should destroy course_types_subject" do
    assert_difference('CourseTypesSubject.count', -1) do
      delete :destroy, id: @course_types_subject
    end

    assert_redirected_to course_types_subjects_path
  end
end
