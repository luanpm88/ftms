json.array!(@related_contacts) do |related_contact|
  json.extract! related_contact, :id, :contact_ids
  json.url related_contact_url(related_contact, format: :json)
end
