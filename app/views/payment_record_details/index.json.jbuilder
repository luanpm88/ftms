json.array!(@payment_record_details) do |payment_record_detail|
  json.extract! payment_record_detail, :id, :contacts_course_id, :books_contact_id, :amount
  json.url payment_record_detail_url(payment_record_detail, format: :json)
end
