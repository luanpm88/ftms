json.array!(@activities) do |activity|
  json.extract! activity, :id, :user_id, :contact_id, :note
  json.url activity_url(activity, format: :json)
end
