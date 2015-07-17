json.array!(@courses_phrases) do |courses_phrase|
  json.extract! courses_phrase, :id, :course_id, :phrase_id
  json.url courses_phrase_url(courses_phrase, format: :json)
end
