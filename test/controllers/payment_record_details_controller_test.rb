require 'test_helper'

class PaymentRecordDetailsControllerTest < ActionController::TestCase
  setup do
    @payment_record_detail = payment_record_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payment_record_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payment_record_detail" do
    assert_difference('PaymentRecordDetail.count') do
      post :create, payment_record_detail: { amount: @payment_record_detail.amount, books_contact_id: @payment_record_detail.books_contact_id, contacts_course_id: @payment_record_detail.contacts_course_id }
    end

    assert_redirected_to payment_record_detail_path(assigns(:payment_record_detail))
  end

  test "should show payment_record_detail" do
    get :show, id: @payment_record_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @payment_record_detail
    assert_response :success
  end

  test "should update payment_record_detail" do
    patch :update, id: @payment_record_detail, payment_record_detail: { amount: @payment_record_detail.amount, books_contact_id: @payment_record_detail.books_contact_id, contacts_course_id: @payment_record_detail.contacts_course_id }
    assert_redirected_to payment_record_detail_path(assigns(:payment_record_detail))
  end

  test "should destroy payment_record_detail" do
    assert_difference('PaymentRecordDetail.count', -1) do
      delete :destroy, id: @payment_record_detail
    end

    assert_redirected_to payment_record_details_path
  end
end
