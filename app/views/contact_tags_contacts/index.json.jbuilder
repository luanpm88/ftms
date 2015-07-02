json.array!(@contact_tags_contacts) do |contact_tags_contact|
  json.extract! contact_tags_contact, :id, :contact_id, :contact_type_id, :user_id
  json.url contact_tags_contact_url(contact_tags_contact, format: :json)
end
