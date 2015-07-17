json.array!(@discount_programs) do |discount_program|
  json.extract! discount_program, :id, :name, :user_id, :start_at, :end_at, :rate
  json.url discount_program_url(discount_program, format: :json)
end
