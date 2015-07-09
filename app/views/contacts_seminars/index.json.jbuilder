json.array!(@contacts_seminars) do |contacts_seminar|
  json.extract! contacts_seminar, :id, :contact_id, :seminar_id
  json.url contacts_seminar_url(contacts_seminar, format: :json)
end
