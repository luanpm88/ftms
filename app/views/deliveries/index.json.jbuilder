json.array!(@deliveries) do |delivery|
  json.extract! delivery, :id, :course_register_id, :contact_id, :delivery_date, :user_id
  json.url delivery_url(delivery, format: :json)
end
