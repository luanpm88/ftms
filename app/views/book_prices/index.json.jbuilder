json.array!(@book_prices) do |book_price|
  json.extract! book_price, :id, :book_id, :prices, :user_id
  json.url book_price_url(book_price, format: :json)
end
