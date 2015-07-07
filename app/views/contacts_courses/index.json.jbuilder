json.array!(@contacts_courses) do |contacts_course|
  json.extract! contacts_course, :id, :contact_id, :course_id, :course_register_id
  json.url contacts_course_url(contacts_course, format: :json)
end
