json.array!(@transfer_details) do |transfer_detail|
  json.extract! transfer_detail, :id, :transfer_id, :contacts_course_id, :courses_phrase_ids
  json.url transfer_detail_url(transfer_detail, format: :json)
end
