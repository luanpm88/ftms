json.array!(@seminars) do |seminar|
  json.extract! seminar, :id, :name, :description, :start_at
  json.url seminar_url(seminar, format: :json)
end
