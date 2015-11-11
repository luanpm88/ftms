require 'test_helper'

class RelatedContactsControllerTest < ActionController::TestCase
  setup do
    @related_contact = related_contacts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:related_contacts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create related_contact" do
    assert_difference('RelatedContact.count') do
      post :create, related_contact: { contact_ids: @related_contact.contact_ids }
    end

    assert_redirected_to related_contact_path(assigns(:related_contact))
  end

  test "should show related_contact" do
    get :show, id: @related_contact
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @related_contact
    assert_response :success
  end

  test "should update related_contact" do
    patch :update, id: @related_contact, related_contact: { contact_ids: @related_contact.contact_ids }
    assert_redirected_to related_contact_path(assigns(:related_contact))
  end

  test "should destroy related_contact" do
    assert_difference('RelatedContact.count', -1) do
      delete :destroy, id: @related_contact
    end

    assert_redirected_to related_contacts_path
  end
end
