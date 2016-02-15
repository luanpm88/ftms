json.array!(@sales_targets) do |sales_target|
  json.extract! sales_target, :id, :staff_id, :report_period_id, :user_id
  json.url sales_target_url(sales_target, format: :json)
end
