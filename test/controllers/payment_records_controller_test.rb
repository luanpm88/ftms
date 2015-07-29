require 'test_helper'

class PaymentRecordsControllerTest < ActionController::TestCase
  setup do
    @payment_record = payment_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payment_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payment_record" do
    assert_difference('PaymentRecord.count') do
      post :create, payment_record: { amount: @payment_record.amount, contact_id: @payment_record.contact_id, course_register_id: @payment_record.course_register_id, debt_date: @payment_record.debt_date, note: @payment_record.note, user_id: @payment_record.user_id }
    end

    assert_redirected_to payment_record_path(assigns(:payment_record))
  end

  test "should show payment_record" do
    get :show, id: @payment_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @payment_record
    assert_response :success
  end

  test "should update payment_record" do
    patch :update, id: @payment_record, payment_record: { amount: @payment_record.amount, contact_id: @payment_record.contact_id, course_register_id: @payment_record.course_register_id, debt_date: @payment_record.debt_date, note: @payment_record.note, user_id: @payment_record.user_id }
    assert_redirected_to payment_record_path(assigns(:payment_record))
  end

  test "should destroy payment_record" do
    assert_difference('PaymentRecord.count', -1) do
      delete :destroy, id: @payment_record
    end

    assert_redirected_to payment_records_path
  end
end
