require 'test_helper'

class CoursesPhrasesControllerTest < ActionController::TestCase
  setup do
    @courses_phrase = courses_phrases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:courses_phrases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create courses_phrase" do
    assert_difference('CoursesPhrase.count') do
      post :create, courses_phrase: { course_id: @courses_phrase.course_id, phrase_id: @courses_phrase.phrase_id }
    end

    assert_redirected_to courses_phrase_path(assigns(:courses_phrase))
  end

  test "should show courses_phrase" do
    get :show, id: @courses_phrase
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @courses_phrase
    assert_response :success
  end

  test "should update courses_phrase" do
    patch :update, id: @courses_phrase, courses_phrase: { course_id: @courses_phrase.course_id, phrase_id: @courses_phrase.phrase_id }
    assert_redirected_to courses_phrase_path(assigns(:courses_phrase))
  end

  test "should destroy courses_phrase" do
    assert_difference('CoursesPhrase.count', -1) do
      delete :destroy, id: @courses_phrase
    end

    assert_redirected_to courses_phrases_path
  end
end
