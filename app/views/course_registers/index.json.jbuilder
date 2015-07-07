json.array!(@course_registers) do |course_register|
  json.extract! course_register, :id, :created_date, :user_id
  json.url course_register_url(course_register, format: :json)
end
