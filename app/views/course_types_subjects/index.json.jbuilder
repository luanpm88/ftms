json.array!(@course_types_subjects) do |course_types_subject|
  json.extract! course_types_subject, :id, :course_type_id, :subject_id
  json.url course_types_subject_url(course_types_subject, format: :json)
end
