json.array!(@transfers) do |transfer|
  json.extract! transfer, :id, :contact_id, :user_id, :transfer_date, :hours, :money
  json.url transfer_url(transfer, format: :json)
end
