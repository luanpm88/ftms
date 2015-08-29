require 'test_helper'

class TransferDetailsControllerTest < ActionController::TestCase
  setup do
    @transfer_detail = transfer_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transfer_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transfer_detail" do
    assert_difference('TransferDetail.count') do
      post :create, transfer_detail: { contacts_course_id: @transfer_detail.contacts_course_id, courses_phrase_ids: @transfer_detail.courses_phrase_ids, transfer_id: @transfer_detail.transfer_id }
    end

    assert_redirected_to transfer_detail_path(assigns(:transfer_detail))
  end

  test "should show transfer_detail" do
    get :show, id: @transfer_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transfer_detail
    assert_response :success
  end

  test "should update transfer_detail" do
    patch :update, id: @transfer_detail, transfer_detail: { contacts_course_id: @transfer_detail.contacts_course_id, courses_phrase_ids: @transfer_detail.courses_phrase_ids, transfer_id: @transfer_detail.transfer_id }
    assert_redirected_to transfer_detail_path(assigns(:transfer_detail))
  end

  test "should destroy transfer_detail" do
    assert_difference('TransferDetail.count', -1) do
      delete :destroy, id: @transfer_detail
    end

    assert_redirected_to transfer_details_path
  end
end
