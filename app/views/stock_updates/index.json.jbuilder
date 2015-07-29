json.array!(@stock_updates) do |stock_update|
  json.extract! stock_update, :id, :type, :book_id, :quantity, :created_date, :user_id
  json.url stock_update_url(stock_update, format: :json)
end
