require 'test_helper'

class DiscountProgramsControllerTest < ActionController::TestCase
  setup do
    @discount_program = discount_programs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:discount_programs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create discount_program" do
    assert_difference('DiscountProgram.count') do
      post :create, discount_program: { end_at: @discount_program.end_at, name: @discount_program.name, rate: @discount_program.rate, start_at: @discount_program.start_at, user_id: @discount_program.user_id }
    end

    assert_redirected_to discount_program_path(assigns(:discount_program))
  end

  test "should show discount_program" do
    get :show, id: @discount_program
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @discount_program
    assert_response :success
  end

  test "should update discount_program" do
    patch :update, id: @discount_program, discount_program: { end_at: @discount_program.end_at, name: @discount_program.name, rate: @discount_program.rate, start_at: @discount_program.start_at, user_id: @discount_program.user_id }
    assert_redirected_to discount_program_path(assigns(:discount_program))
  end

  test "should destroy discount_program" do
    assert_difference('DiscountProgram.count', -1) do
      delete :destroy, id: @discount_program
    end

    assert_redirected_to discount_programs_path
  end
end
