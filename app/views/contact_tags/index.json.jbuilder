json.array!(@contact_tags) do |contact_tag|
  json.extract! contact_tag, :id, :name, :description
  json.url contact_tag_url(contact_tag, format: :json)
end
