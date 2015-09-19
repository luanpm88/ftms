json.array!(@stock_types) do |stock_type|
  json.extract! stock_type, :id, :name, :description, :user_id, :annoucing_user_ids, :parent_id, :status
  json.url stock_type_url(stock_type, format: :json)
end
