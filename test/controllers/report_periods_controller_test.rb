require 'test_helper'

class ReportPeriodsControllerTest < ActionController::TestCase
  setup do
    @report_period = report_periods(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_periods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report_period" do
    assert_difference('ReportPeriod.count') do
      post :create, report_period: { end_at: @report_period.end_at, name: @report_period.name, start_at: @report_period.start_at, status: @report_period.status, user_id: @report_period.user_id }
    end

    assert_redirected_to report_period_path(assigns(:report_period))
  end

  test "should show report_period" do
    get :show, id: @report_period
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report_period
    assert_response :success
  end

  test "should update report_period" do
    patch :update, id: @report_period, report_period: { end_at: @report_period.end_at, name: @report_period.name, start_at: @report_period.start_at, status: @report_period.status, user_id: @report_period.user_id }
    assert_redirected_to report_period_path(assigns(:report_period))
  end

  test "should destroy report_period" do
    assert_difference('ReportPeriod.count', -1) do
      delete :destroy, id: @report_period
    end

    assert_redirected_to report_periods_path
  end
end
