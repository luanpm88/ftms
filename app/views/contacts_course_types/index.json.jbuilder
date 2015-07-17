json.array!(@contacts_course_types) do |contacts_course_type|
  json.extract! contacts_course_type, :id, :contact_id, :course_type_id
  json.url contacts_course_type_url(contacts_course_type, format: :json)
end
