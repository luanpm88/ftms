json.array!(@course_types_discount_programs) do |course_types_discount_program|
  json.extract! course_types_discount_program, :id, :course_type_id, :discount_program_id
  json.url course_types_discount_program_url(course_types_discount_program, format: :json)
end
