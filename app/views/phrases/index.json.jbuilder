json.array!(@phrases) do |phrase|
  json.extract! phrase, :id, :name, :subject_id
  json.url phrase_url(phrase, format: :json)
end
