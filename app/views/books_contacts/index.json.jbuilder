json.array!(@books_contacts) do |books_contact|
  json.extract! books_contact, :id, :course_register_id, :book_id, :contact_id, :price, :discount_program_id, :discount, :volumn_ids
  json.url books_contact_url(books_contact, format: :json)
end
