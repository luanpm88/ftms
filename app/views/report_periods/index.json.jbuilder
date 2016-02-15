json.array!(@report_periods) do |report_period|
  json.extract! report_period, :id, :user_id, :name, :start_at, :end_at, :status
  json.url report_period_url(report_period, format: :json)
end
