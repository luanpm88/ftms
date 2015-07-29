json.array!(@payment_records) do |payment_record|
  json.extract! payment_record, :id, :course_register_id, :amount, :debt_date, :contact_id, :user_id, :note
  json.url payment_record_url(payment_record, format: :json)
end
