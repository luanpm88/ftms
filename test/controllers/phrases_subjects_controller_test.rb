require 'test_helper'

class PhrasesSubjectsControllerTest < ActionController::TestCase
  setup do
    @phrases_subject = phrases_subjects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:phrases_subjects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create phrases_subject" do
    assert_difference('PhrasesSubject.count') do
      post :create, phrases_subject: { phrase_id: @phrases_subject.phrase_id, subject_id: @phrases_subject.subject_id }
    end

    assert_redirected_to phrases_subject_path(assigns(:phrases_subject))
  end

  test "should show phrases_subject" do
    get :show, id: @phrases_subject
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @phrases_subject
    assert_response :success
  end

  test "should update phrases_subject" do
    patch :update, id: @phrases_subject, phrases_subject: { phrase_id: @phrases_subject.phrase_id, subject_id: @phrases_subject.subject_id }
    assert_redirected_to phrases_subject_path(assigns(:phrases_subject))
  end

  test "should destroy phrases_subject" do
    assert_difference('PhrasesSubject.count', -1) do
      delete :destroy, id: @phrases_subject
    end

    assert_redirected_to phrases_subjects_path
  end
end
