require 'test_helper'

class ContactTagsContactsControllerTest < ActionController::TestCase
  setup do
    @contact_tags_contact = contact_tags_contacts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contact_tags_contacts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contact_tags_contact" do
    assert_difference('ContactTagsContact.count') do
      post :create, contact_tags_contact: { contact_id: @contact_tags_contact.contact_id, contact_type_id: @contact_tags_contact.contact_type_id, user_id: @contact_tags_contact.user_id }
    end

    assert_redirected_to contact_tags_contact_path(assigns(:contact_tags_contact))
  end

  test "should show contact_tags_contact" do
    get :show, id: @contact_tags_contact
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contact_tags_contact
    assert_response :success
  end

  test "should update contact_tags_contact" do
    patch :update, id: @contact_tags_contact, contact_tags_contact: { contact_id: @contact_tags_contact.contact_id, contact_type_id: @contact_tags_contact.contact_type_id, user_id: @contact_tags_contact.user_id }
    assert_redirected_to contact_tags_contact_path(assigns(:contact_tags_contact))
  end

  test "should destroy contact_tags_contact" do
    assert_difference('ContactTagsContact.count', -1) do
      delete :destroy, id: @contact_tags_contact
    end

    assert_redirected_to contact_tags_contacts_path
  end
end
