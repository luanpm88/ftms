json.array!(@phrases_subjects) do |phrases_subject|
  json.extract! phrases_subject, :id, :phrase_id, :subject_id
  json.url phrases_subject_url(phrases_subject, format: :json)
end
