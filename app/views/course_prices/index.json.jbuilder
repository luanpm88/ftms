json.array!(@course_prices) do |course_price|
  json.extract! course_price, :id, :course_id, :prices, :user_id
  json.url course_price_url(course_price, format: :json)
end
