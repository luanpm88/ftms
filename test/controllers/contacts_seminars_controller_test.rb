require 'test_helper'

class ContactsSeminarsControllerTest < ActionController::TestCase
  setup do
    @contacts_seminar = contacts_seminars(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contacts_seminars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contacts_seminar" do
    assert_difference('ContactsSeminar.count') do
      post :create, contacts_seminar: { contact_id: @contacts_seminar.contact_id, seminar_id: @contacts_seminar.seminar_id }
    end

    assert_redirected_to contacts_seminar_path(assigns(:contacts_seminar))
  end

  test "should show contacts_seminar" do
    get :show, id: @contacts_seminar
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contacts_seminar
    assert_response :success
  end

  test "should update contacts_seminar" do
    patch :update, id: @contacts_seminar, contacts_seminar: { contact_id: @contacts_seminar.contact_id, seminar_id: @contacts_seminar.seminar_id }
    assert_redirected_to contacts_seminar_path(assigns(:contacts_seminar))
  end

  test "should destroy contacts_seminar" do
    assert_difference('ContactsSeminar.count', -1) do
      delete :destroy, id: @contacts_seminar
    end

    assert_redirected_to contacts_seminars_path
  end
end
