require 'test_helper'

class ContactTagsControllerTest < ActionController::TestCase
  setup do
    @contact_tag = contact_tags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contact_tags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contact_tag" do
    assert_difference('ContactTag.count') do
      post :create, contact_tag: { description: @contact_tag.description, name: @contact_tag.name }
    end

    assert_redirected_to contact_tag_path(assigns(:contact_tag))
  end

  test "should show contact_tag" do
    get :show, id: @contact_tag
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contact_tag
    assert_response :success
  end

  test "should update contact_tag" do
    patch :update, id: @contact_tag, contact_tag: { description: @contact_tag.description, name: @contact_tag.name }
    assert_redirected_to contact_tag_path(assigns(:contact_tag))
  end

  test "should destroy contact_tag" do
    assert_difference('ContactTag.count', -1) do
      delete :destroy, id: @contact_tag
    end

    assert_redirected_to contact_tags_path
  end
end
